import Foundation
import SwiftSoup

struct GearItemMetadata {
    let name: String
    let weightGrams: Double?
    let rawWeightString: String?
    let sourceURL: URL
}

enum MetadataFetchError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case parseFailure(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .parseFailure(let d): return "Parse failure: \(d)"
        }
    }
}

actor URLMetadataFetcher {

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            "Accept": "text/html,application/xhtml+xml,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9"
        ]
        session = URLSession(configuration: config)
    }

    func fetch(url: URL) async throws -> GearItemMetadata {
        let host = url.host?.lowercased() ?? ""

        // Shopify stores: use the public .json product API
        let shopifyHosts = ["zpacks.com", "gossamergear.com", "ula-equipment.com",
                            "mountainlaureldesigns.com", "sixmoondesigns.com",
                            "tarptent.com", "hyperlitemountaingear.com"]
        if shopifyHosts.contains(where: { host.contains($0) }) {
            return try await fetchShopify(url: url)
        }
        if host.contains("rei.com") {
            return try await fetchREI(url: url)
        }
        if host.contains("backcountry.com") {
            return try await fetchBackcountry(url: url)
        }
        return try await fetchGeneric(url: url)
    }

    // MARK: - Shopify

    private func fetchShopify(url: URL) async throws -> GearItemMetadata {
        if let jsonURL = shopifyJSONURL(from: url),
           let (data, resp) = try? await session.data(from: jsonURL),
           (resp as? HTTPURLResponse)?.statusCode == 200,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let product = json["product"] as? [String: Any],
           let name = product["title"] as? String, !name.isEmpty {

            // Try variant weight field first
            if let variants = product["variants"] as? [[String: Any]],
               let first = variants.first,
               let w = first["weight"] as? Double, w > 0,
               let unit = first["weight_unit"] as? String {
                return GearItemMetadata(name: name, weightGrams: convertToGrams(w, unit: unit),
                                        rawWeightString: "\(w) \(unit)", sourceURL: url)
            }

            // Fall back to description text
            let body = product["body_html"] as? String ?? ""
            let (raw, grams) = extractWeight(from: body)
            return GearItemMetadata(name: name, weightGrams: grams, rawWeightString: raw, sourceURL: url)
        }
        return try await fetchGeneric(url: url)
    }

    private func shopifyJSONURL(from url: URL) -> URL? {
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        comps?.query = nil
        comps?.fragment = nil
        guard var path = comps?.path else { return nil }
        if let r = path.range(of: "/variants/") { path = String(path[..<r.lowerBound]) }
        if path.hasSuffix("/") { path = String(path.dropLast()) }
        comps?.path = path + ".json"
        return comps?.url
    }

    // MARK: - REI

    private func fetchREI(url: URL) async throws -> GearItemMetadata {
        let html = try await fetchHTML(url: url)
        let doc = try SwiftSoup.parse(html)

        var name: String? = nil
        var weightGrams: Double? = nil
        var rawWeight: String? = nil

        // JSON-LD for name
        for script in try doc.select("script[type='application/ld+json']") {
            if let json = try? JSONSerialization.jsonObject(with: Data(script.html().utf8)) as? [String: Any],
               (json["@type"] as? String) == "Product" {
                name = json["name"] as? String
                break
            }
        }

        // Specs table for weight
        let labels = ["Trail Weight", "Pack Weight", "Weight", "Minimum Weight"]
        outer: for item in try doc.select("[data-ui='product-specs'] li, .rei-c-table__row, [class*='spec'] li") {
            let text = try item.text()
            for label in labels where text.localizedCaseInsensitiveContains(label) {
                let (raw, g) = extractWeight(from: text)
                if g != nil { rawWeight = raw; weightGrams = g; break outer }
            }
        }

        // og:title fallback
        if name == nil {
            name = try doc.select("meta[property='og:title']").first()?.attr("content") ?? doc.title()
        }

        guard let finalName = name, !finalName.isEmpty else {
            throw MetadataFetchError.parseFailure("No product name found on REI page")
        }

        return GearItemMetadata(name: clean(finalName), weightGrams: weightGrams,
                                rawWeightString: rawWeight, sourceURL: url)
    }

    // MARK: - Backcountry

    private func fetchBackcountry(url: URL) async throws -> GearItemMetadata {
        let html = try await fetchHTML(url: url)
        let doc = try SwiftSoup.parse(html)

        var name: String? = nil
        var weightGrams: Double? = nil
        var rawWeight: String? = nil

        // __INITIAL_STATE__ JSON blob
        for script in try doc.select("script:not([src])") {
            let content = try script.html()
            guard content.hasPrefix("window.__INITIAL_STATE__") else { continue }
            var jsonStr = content
            if let eq = jsonStr.range(of: "= ") { jsonStr = String(jsonStr[eq.upperBound...]) }
            if jsonStr.hasSuffix(";") { jsonStr = String(jsonStr.dropLast()) }
            if let data = jsonStr.data(using: .utf8),
               let state = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let catalog = state["catalog"] as? [String: Any],
               let products = catalog["products"] as? [String: Any],
               let first = products.values.first as? [String: Any] {
                name = first["displayName"] as? String ?? first["name"] as? String
                if let specs = first["specs"] as? [[String: Any]] {
                    for spec in specs where (spec["name"] as? String ?? "").localizedCaseInsensitiveContains("weight") {
                        rawWeight = spec["value"] as? String
                        weightGrams = rawWeight.flatMap { WeightParser.parseToGrams($0) }
                        break
                    }
                }
            }
            break
        }

        // Specs table fallback
        if weightGrams == nil {
            for dt in try doc.select("[data-testid='product-specs'] dt, dl dt") {
                if (try dt.text()).localizedCaseInsensitiveContains("weight"),
                   let dd = try dt.nextElementSibling() {
                    rawWeight = try dd.text()
                    weightGrams = rawWeight.flatMap { WeightParser.parseToGrams($0) }
                    break
                }
            }
        }

        if name == nil {
            name = try doc.select("meta[property='og:title']").first()?.attr("content")
        }

        guard let finalName = name, !finalName.isEmpty else {
            throw MetadataFetchError.parseFailure("No product name found on Backcountry page")
        }

        return GearItemMetadata(name: clean(finalName), weightGrams: weightGrams,
                                rawWeightString: rawWeight, sourceURL: url)
    }

    // MARK: - Generic fallback

    private func fetchGeneric(url: URL) async throws -> GearItemMetadata {
        let html = try await fetchHTML(url: url)
        let doc = try SwiftSoup.parse(html)

        var name: String? = nil
        var weightGrams: Double? = nil
        var rawWeight: String? = nil

        for script in try doc.select("script[type='application/ld+json']") {
            guard let json = try? JSONSerialization.jsonObject(with: Data(script.html().utf8)) as? [String: Any] else { continue }
            let product: [String: Any]?
            if (json["@type"] as? String) == "Product" {
                product = json
            } else if let graph = json["@graph"] as? [[String: Any]] {
                product = graph.first { ($0["@type"] as? String) == "Product" }
            } else {
                product = nil
            }
            guard let p = product else { continue }
            name = p["name"] as? String
            if let desc = p["description"] as? String {
                let (raw, g) = extractWeight(from: desc)
                rawWeight = raw; weightGrams = g
            }
            break
        }

        if name == nil {
            name = try doc.select("meta[property='og:title']").first()?.attr("content") ?? doc.title()
        }
        // HTML spec tables: <th>Weight...</th> <td>value</td>  or  <dt>Weight</dt><dd>value</dd>
        if weightGrams == nil {
            let weightLabels = ["pack weight", "trail weight", "weight (pounds)",
                                "weight (kilograms)", "weight (grams)", "weight"]
            for row in try doc.select("tr") {
                let cells = try row.select("th, td")
                guard cells.size() >= 2 else { continue }
                let label = (try? cells.get(0).text().lowercased()) ?? ""
                if weightLabels.contains(where: { label.contains($0) }) {
                    let value = (try? cells.get(1).text()) ?? ""
                    let (raw, g) = extractWeight(from: value)
                    if g != nil { rawWeight = raw; weightGrams = g; break }
                }
            }
        }
        if weightGrams == nil {
            for dt in try doc.select("dt") {
                if (try dt.text()).lowercased().contains("weight"),
                   let dd = try dt.nextElementSibling() {
                    let (raw, g) = extractWeight(from: try dd.text())
                    if g != nil { rawWeight = raw; weightGrams = g; break }
                }
            }
        }
        if weightGrams == nil {
            for src in [try doc.select("meta[property='og:description']").first()?.attr("content"),
                        try doc.select("meta[name='description']").first()?.attr("content")].compactMap({ $0 }) {
                let (raw, g) = extractWeight(from: src)
                if g != nil { rawWeight = raw; weightGrams = g; break }
            }
        }

        guard let finalName = name, !finalName.isEmpty else {
            throw MetadataFetchError.parseFailure("Could not extract product name")
        }

        return GearItemMetadata(name: finalName, weightGrams: weightGrams,
                                rawWeightString: rawWeight, sourceURL: url)
    }

    // MARK: - Helpers

    private func fetchHTML(url: URL) async throws -> String {
        do {
            let (data, response) = try await session.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw MetadataFetchError.parseFailure("HTTP \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            }
            guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                throw MetadataFetchError.parseFailure("Could not decode response")
            }
            return html
        } catch let e as MetadataFetchError {
            throw e
        } catch {
            throw MetadataFetchError.networkError(error)
        }
    }

    private func extractWeight(from text: String) -> (String?, Double?) {
        let cleaned = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        let labeled = #"(?:trail\s+weight|pack\s+weight|weight)[:\s]+([0-9][^\n<]{2,30})"#
        if let regex = try? NSRegularExpression(pattern: labeled, options: .caseInsensitive),
           let match = regex.firstMatch(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)),
           let range = Range(match.range(at: 1), in: cleaned) {
            let candidate = String(cleaned[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if let g = WeightParser.parseToGrams(candidate) { return (candidate, g) }
        }
        let unlabeled = #"(\d+(?:\.\d+)?\s*(?:lbs?\.?|oz\.?|g|grams?|kg)(?:[^A-Za-z0-9]\d+(?:\.\d+)?\s*(?:lbs?\.?|oz\.?|g|grams?))?)"#
        if let regex = try? NSRegularExpression(pattern: unlabeled, options: .caseInsensitive),
           let match = regex.firstMatch(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)),
           let range = Range(match.range(at: 1), in: cleaned) {
            let candidate = String(cleaned[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if let g = WeightParser.parseToGrams(candidate) { return (candidate, g) }
        }
        return (nil, nil)
    }

    private func convertToGrams(_ value: Double, unit: String) -> Double {
        switch unit.lowercased() {
        case "g": return value
        case "kg": return value * 1000
        case "oz": return value * 28.3495
        case "lb": return value * 453.592
        default: return value
        }
    }

    private func clean(_ name: String) -> String {
        let suffixes = [" | REI Co-op", " - REI", " | Backcountry", " - Backcountry.com",
                        " – Gossamer Gear", " - Zpacks", " | Free Shipping"]
        var s = name
        for suffix in suffixes where s.hasSuffix(suffix) {
            s = String(s.dropLast(suffix.count))
        }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

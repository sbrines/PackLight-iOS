import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportButton: View {
    let items: [GearItem]

    @State private var isExporting = false
    @State private var exportURL: URL? = nil

    var body: some View {
        Button("Export to CSV", systemImage: "square.and.arrow.up") {
            exportURL = writeCSV()
            isExporting = exportURL != nil
        }
        .sheet(isPresented: $isExporting) {
            if let url = exportURL {
                ShareSheetView(items: [url])
            }
        }
    }

    private func writeCSV() -> URL? {
        let csv = LighterpackService.export(items: items)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("packlight-gear.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}

struct ImportCSVView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var isPickingFile = false
    @State private var importedRows: [LighterpackRow] = []
    @State private var importError: String? = nil
    @State private var showPreview = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text("Import from Lighterpack")
                        .font(.title2.bold())
                    Text("Import a CSV exported from Lighterpack.com or any compatible app.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }

                Button("Choose CSV File", systemImage: "doc") {
                    isPickingFile = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if let error = importError {
                    Label(error, systemImage: "exclamationmark.circle")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            .padding(32)
            .navigationTitle("Import Gear")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $isPickingFile,
                allowedContentTypes: [UTType.commaSeparatedText, UTType.plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    parseFile(url: url)
                case .failure(let error):
                    importError = error.localizedDescription
                }
            }
            .sheet(isPresented: $showPreview) {
                ImportPreviewView(rows: importedRows) { selectedRows in
                    commitImport(rows: selectedRows)
                }
            }
        }
    }

    private func parseFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        do {
            let csv = try String(contentsOf: url, encoding: .utf8)
            importedRows = try LighterpackService.import(csv: csv)
            importError = nil
            showPreview = true
        } catch {
            importError = error.localizedDescription
        }
    }

    private func commitImport(rows: [LighterpackRow]) {
        let items = LighterpackService.rowsToGearItems(rows)
        for item in items { context.insert(item) }
        try? context.save()
        dismiss()
    }
}

struct ImportPreviewView: View {
    let rows: [LighterpackRow]
    let onImport: ([LighterpackRow]) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Set<Int> = []

    var body: some View {
        NavigationStack {
            List(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack {
                    Image(systemName: selected.contains(index) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selected.contains(index) ? .blue : .secondary)
                        .onTapGesture {
                            if selected.contains(index) { selected.remove(index) }
                            else { selected.insert(index) }
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.name).font(.body)
                        Text("\(row.category) · \(WeightParser.displayString(row.weightGrams))")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("×\(row.quantity)").foregroundStyle(.secondary).font(.caption)
                }
            }
            .navigationTitle("Preview (\(rows.count) items)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Import \(selected.isEmpty ? "All" : "\(selected.count)")") {
                        let toImport = selected.isEmpty ? rows : selected.sorted().map { rows[$0] }
                        onImport(toImport)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button(selected.count == rows.count ? "Deselect All" : "Select All") {
                        if selected.count == rows.count { selected.removeAll() }
                        else { selected = Set(0..<rows.count) }
                    }
                }
            }
            .onAppear { selected = Set(0..<rows.count) }
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PackListShareButton: View {
    let packList: PackList
    @State private var isSharing = false
    @State private var shareURL: URL? = nil

    var body: some View {
        Button("Share Pack List", systemImage: "square.and.arrow.up") {
            shareURL = writeCSV()
            isSharing = shareURL != nil
        }
        .sheet(isPresented: $isSharing) {
            if let url = shareURL {
                ShareSheetView(items: [url])
            }
        }
    }

    private func writeCSV() -> URL? {
        let csv = LighterpackService.exportPackList(packList: packList)
        let name = packList.name.replacingOccurrences(of: " ", with: "-").lowercased()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(name).csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch { return nil }
    }
}

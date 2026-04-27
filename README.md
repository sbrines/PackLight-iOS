# PackLight — iOS & macOS

**Ultralight backpacking trip planner for iOS 17+ and macOS 14+**

> The modern alternative to Lighterpack. Native, offline-first, and built for serious UL hikers.

---

## Features

| Feature | Details |
|---|---|
| **Gear Inventory** | Full gear library with category, brand, weight, quantity, and notes |
| **URL Auto-Import** | Paste a product URL from REI, Zpacks, Gossamer Gear, ULA, and more — name and weight are fetched automatically |
| **Pack Builder** | Build trip-specific pack lists from your inventory; mark items as worn or consumable |
| **Weight Calculator** | Real-time base weight, skin-out weight, and total pack weight with SUL/UL/Lightweight/Traditional classification |
| **Resupply Logistics** | Plan resupply boxes with mile markers, shipping addresses, and pick-up status |
| **Gear Recommendations** | Route-aware recommendations based on elevation, season, terrain, and trip duration |
| **Lighterpack Import/Export** | Import from lighterpack.com CSV; export any gear list or pack list |
| **Pack List Sharing** | Share a pack list CSV via the system share sheet |
| **macOS Optimized** | NavigationSplitView sidebar, ⌘1/2/3 section switching, ⌘N new items, native window sizing |

---

## Tech Stack

- **SwiftUI** + **SwiftData** (iOS 17 / macOS 14)
- **xcodegen** for project generation
- **SwiftSoup** (HTML parsing for URL weight extraction)
- **Charts** framework for weight breakdown visualization
- `@Observable` ViewModels (no ObservableObject/Combine)
- Static `WeightCalculator` service, `actor`-based `URLMetadataFetcher`

---

## Architecture

```
Sources/PackLight/
├── Models/          # SwiftData @Model — GearItem, Trip, PackList, PackListItem,
│                    #   ResupplyPoint, ResupplyPointItem
├── Services/        # WeightCalculator, WeightParser, URLMetadataFetcher,
│                    #   GearRecommendationEngine, LighterpackService
├── ViewModels/      # @Observable — GearViewModel, TripViewModel, WeightViewModel
└── Views/
    ├── Gear/        # GearListView, GearItemDetailView, AddGearItemView, ImportExportView
    ├── Trips/       # TripListView, TripDetailView, PackListView, ResupplyPointDetailView,
    │                #   RecommendationsView, AddTripView
    ├── Weight/      # WeightDashboardView
    └── Mac/         # MacContentView (NavigationSplitView + PackLightCommands)
```

**Weight classification thresholds:**
- Super Ultralight (SUL): base weight < 5 lbs (2,270g)
- Ultralight (UL): base weight < 10 lbs (4,540g)
- Lightweight: base weight < 20 lbs (9,070g)
- Traditional: 20 lbs+

---

## URL Weight Fetching

Supported retailers with automatic weight extraction:

| Site | Method | Confidence |
|---|---|---|
| Zpacks, Gossamer Gear, ULA, MLD, Six Moon, Tarptent, HMG | Shopify `.json` API endpoint | High |
| REI | SSR JSON-LD + specs table | Medium |
| Backcountry | `__INITIAL_STATE__` JSON + specs table | Medium |
| Any other site | Open Graph meta + JSON-LD schema.org | Low |

---

## Requirements

- Xcode 15+
- iOS 17.0+ / macOS 14.0+
- [xcodegen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Building

```bash
git clone https://github.com/sbrines/PackLight-iOS
cd PackLight-iOS
xcodegen generate
open PackLight.xcodeproj
```

To run on macOS: select **My Mac (Designed for iPad)** as the run destination.

---

## Tests

```bash
xcodebuild test -project PackLight.xcodeproj -scheme PackLight -destination 'platform=iOS Simulator,name=iPhone 16'
```

**Test coverage:**
- `WeightParserTests` — all weight format strings
- `WeightCalculatorTests` — classification, category breakdown, worn/consumable split
- `GearRecommendationTests` — elevation, season, terrain, trip duration logic
- `LighterpackServiceTests` — import/export round-trip, quoted fields, unit conversion

---

## Related Repos

- **Android**: [PackLight-Android](https://github.com/sbrines/PackLight-Android)
- **Landing page**: [PackLight-Web](https://github.com/sbrines/PackLight-Web)

## Xcode Cloud

CI/CD via Xcode Cloud is configured in App Store Connect. Triggers on push to `main`.

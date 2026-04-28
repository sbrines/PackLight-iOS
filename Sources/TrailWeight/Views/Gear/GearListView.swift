import SwiftUI
import SwiftData

struct GearListView: View {
    @Environment(GearViewModel.self) private var viewModel
    @Environment(\.modelContext) private var context
    @Query(sort: \GearItem.name) private var allItems: [GearItem]

    var body: some View {
        @Bindable var vm = viewModel
        List {
            ForEach(viewModel.filtered(allItems)) { item in
                NavigationLink(destination: GearItemDetailView(item: item)) {
                    GearItemRow(item: item)
                }
            }
            .onDelete { offsets in
                let toDelete = offsets.map { viewModel.filtered(allItems)[$0] }
                viewModel.delete(toDelete, from: context)
            }
        }
        .searchable(text: $vm.searchText, prompt: "Search gear")
        .navigationTitle("Gear Inventory")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") {
                    viewModel.showingAddSheet = true
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    ForEach(GearSortOption.allCases) { option in
                        Button(option.rawValue) { viewModel.sortOption = option }
                    }
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Menu("More", systemImage: "ellipsis.circle") {
                    Button("Import from Lighterpack", systemImage: "square.and.arrow.down") {
                        viewModel.showingImportSheet = true
                    }
                    ExportButton(items: allItems)
                }
            }
        }
        .sheet(isPresented: $vm.showingAddSheet) {
            AddGearItemView()
        }
        .sheet(isPresented: $vm.showingImportSheet) {
            ImportCSVView()
        }
    }
}

private struct GearItemRow: View {
    let item: GearItem

    var body: some View {
        HStack {
            Image(systemName: item.category.symbolName)
                .foregroundStyle(item.category.color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.body)
                if !item.brand.isEmpty {
                    Text(item.brand).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(item.displayWeight)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

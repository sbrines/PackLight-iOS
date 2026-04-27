import SwiftUI
import SwiftData
import Charts

struct WeightDashboardView: View {
    @Environment(WeightViewModel.self) private var viewModel
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    var body: some View {
        @Bindable var vm = viewModel
        List {
            Section("Select Trip") {
                Picker("Trip", selection: $vm.selectedTrip) {
                    Text("None").tag(Optional<Trip>.none)
                    ForEach(trips) { trip in
                        Text(trip.name).tag(Optional(trip))
                    }
                }
                .onChange(of: viewModel.selectedTrip) { _, _ in viewModel.recalculate() }
            }

            if let trip = viewModel.selectedTrip {
                let summary = viewModel.summary

                Section("Weight Summary") {
                    WeightRow(label: "Base Weight", grams: summary.baseWeightGrams,
                              viewModel: viewModel)
                    WeightRow(label: "Worn Weight", grams: summary.wornWeightGrams,
                              viewModel: viewModel)
                    WeightRow(label: "Consumables", grams: summary.consumableWeightGrams,
                              viewModel: viewModel)
                    Divider()
                    WeightRow(label: "Total Pack Weight", grams: summary.totalWeightGrams,
                              viewModel: viewModel, isBold: true)
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(summary.classification).font(.title3.bold())
                        Text("Base weight: \(viewModel.formatted(summary.baseWeightGrams))")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Classification")
                }

                if !summary.byCategory.isEmpty {
                    Section("By Category") {
                        Chart(summary.byCategory) { cat in
                            SectorMark(
                                angle: .value("Weight", cat.weightGrams),
                                innerRadius: .ratio(0.5)
                            )
                            .foregroundStyle(by: .value("Category", cat.categoryName))
                        }
                        .frame(height: 200)

                        ForEach(summary.byCategory) { cat in
                            HStack {
                                Image(systemName: cat.categoryIcon)
                                    .frame(width: 20)
                                Text(cat.categoryName)
                                Spacer()
                                Text(viewModel.formatted(cat.weightGrams))
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.0f%%", cat.percentage))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }
                    }
                }

                Section("Display Unit") {
                    Picker("Unit", selection: $vm.displayUnit) {
                        ForEach(WeightUnit.allCases) { u in
                            Text(u.rawValue).tag(u)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .onChange(of: trip) { _, _ in viewModel.recalculate() }
            }
        }
        .navigationTitle("Weight")
    }
}

private struct WeightRow: View {
    let label: String
    let grams: Double
    let viewModel: WeightViewModel
    var isBold = false

    var body: some View {
        HStack {
            Text(label).fontWeight(isBold ? .semibold : .regular)
            Spacer()
            Text(viewModel.formatted(grams))
                .fontWeight(isBold ? .semibold : .regular)
                .monospacedDigit()
        }
    }
}

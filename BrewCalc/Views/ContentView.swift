import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        NavigationSplitView {
            CalculatorListView(viewModel: viewModel)
        } detail: {
            if let category = viewModel.selectedCategory {
                CalculatorDetailView(
                    viewModel: viewModel.makeDetailViewModel(for: category),
                    onCategoryUpdated: { updated in
                        viewModel.updateCategory(updated)
                    }
                )
                .id(category.id)
            } else {
                ContentUnavailableView(
                    l("calcs"),
                    systemImage: "flask",
                    description: Text("Select a calculator from the sidebar")
                )
            }
        }
        .tint(.brewCalcAccent)
        .sheet(isPresented: $viewModel.showAbout) {
            NavigationStack {
                AboutView()
            }
        }
    }
}

import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        NavigationSplitView {
            CalculatorListView(viewModel: viewModel)
        } detail: {
            if let category = viewModel.selectedCategory {
                CalculatorDetailView(
                    viewModel: CalculatorDetailViewModel(category: category),
                    onCategoryUpdated: { updated in
                        viewModel.updateCategory(updated)
                    }
                )
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

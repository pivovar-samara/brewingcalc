import SwiftUI

struct CalculatorListView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        List(viewModel.categories, selection: $viewModel.selectedCategoryID) { category in
            NavigationLink(value: category.id) {
                Text(category.localizedName)
            }
        }
        .navigationTitle(l("calcs"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(l("menu.right.button")) {
                    viewModel.showAbout = true
                }
            }
        }
    }
}

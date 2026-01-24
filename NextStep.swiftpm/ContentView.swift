import SwiftUI

struct ContentView: View {
    @State private var viewModel = TodoViewModel()
    
    var body: some View {
        Group {
            if viewModel.isOrganized {
                OrganizedTodosView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                FloatingTodosView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.isOrganized)
    }
}

#Preview {
    ContentView()
}

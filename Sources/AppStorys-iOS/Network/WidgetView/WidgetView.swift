import SwiftUI

public struct WidgetView: View {

    private enum Constants {
        static let dotDefaultSize: CGFloat = 10
        static let dotCornerRadius: CGFloat = 5
        static let selectedDotWidth: CGFloat = 25
    }

    @State private var selectedIndex = 0
    @StateObject private var viewModel: WidgetViewModel

    public init(appID: String, accountID: String, screenName: String) {
        self._viewModel = StateObject(wrappedValue: WidgetViewModel(appID: appID, accountID: accountID, screenName: screenName))
    }

    public var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $selectedIndex) {
                ForEach(Array(viewModel.imageUrls.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure, .empty:
                            ProgressView()
                        @unknown default:
                            ProgressView()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: viewModel.widgetHeight)

            HStack(spacing: 6) {
                ForEach(0..<viewModel.imageUrls.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: index == selectedIndex ? Constants.selectedDotWidth : Constants.dotDefaultSize, height: Constants.dotDefaultSize)
                        .foregroundColor(index == selectedIndex ? .black : .gray.opacity(0.5))
                        .animation(.easeInOut(duration: 0.3), value: selectedIndex)
                }
            }
        }
        .frame(height: viewModel.widgetHeight + 50)
        .onAppear {
            viewModel.viewDidLoad()
        }
    }
}

#Preview {
    WidgetView(appID: "afadf960-3975-4ba2-933b-fac71ccc2002",
               accountID: "13555479-077f-445e-87f0-e6eae2e215c5",
               screenName: "Home Screen")
}

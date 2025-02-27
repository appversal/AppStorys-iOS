import SwiftUI
import SDWebImageSwiftUI

public struct WidgetView: View {

    private enum Constants {
        static let dotDefaultSize: CGFloat = 10
        static let dotCornerRadius: CGFloat = 5
        static let selectedDotWidth: CGFloat = 25
    }

    @StateObject private var viewModel: WidgetViewModel

    public init(appID: String, accountID: String, screenName: String, position: String) {
        self._viewModel = StateObject(wrappedValue: WidgetViewModel(appID: appID, accountID: accountID, screenName: screenName, position: position))
    }

    public var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $viewModel.selectedIndex) {
                ForEach(Array(viewModel.images.enumerated()), id: \.offset) { index, image in
                    WebImage(url: URL(string: image.imageURL))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .padding(.vertical)
                        .tag(index)
                        .onTapGesture {
                            viewModel.didTapWidgetImage(at: index)
                        }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: viewModel.widgetHeight)

            HStack(spacing: 6) {
                ForEach(0..<viewModel.images.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: index == viewModel.selectedIndex ? Constants.selectedDotWidth : Constants.dotDefaultSize, height: Constants.dotDefaultSize)
                        .foregroundColor(index == viewModel.selectedIndex ? .black : .gray.opacity(0.5))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedIndex)
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
               screenName: "Home Screen",
               position: "Position")
}

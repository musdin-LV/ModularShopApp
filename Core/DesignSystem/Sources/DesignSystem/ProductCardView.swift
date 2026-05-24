import SwiftUI

public struct ProductCardView: View {
    private let imageURL: URL?
    private let title: String
    private let price: String
    private let description: String
    private let actionTitle: String?
    private let action: (@MainActor @Sendable () -> Void)?

    public init(
        imageURL: URL?,
        title: String,
        price: String,
        description: String,
        actionTitle: String? = nil,
        action: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.imageURL = imageURL
        self.title = title
        self.price = price
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .top, spacing: ShopSpacing.medium) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(ShopColors.surface)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: ShopSpacing.small) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Text(price)
                        .font(.subheadline.weight(.semibold))
                }

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
        }
        .padding(.vertical, ShopSpacing.small)
        .accessibilityElement(children: .combine)
    }
}

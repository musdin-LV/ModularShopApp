import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public enum ShopSpacing {
    public static let xSmall: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
}

public enum ShopColors {
    public static let accent = Color.blue
    #if os(iOS)
    public static let surface = Color(uiColor: .secondarySystemBackground)
    #elseif os(macOS)
    public static let surface = Color(nsColor: .windowBackgroundColor)
    #else
    public static let surface = Color(.secondarySystemBackground)
    #endif
}

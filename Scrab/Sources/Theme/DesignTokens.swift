import SwiftUI

struct DesignTokens {
  // MARK: - Colors (from capturemac.pen variables)
  static let accent = Color(hex: "#007AFF")
  static let bgSurface = Color(hex: "#2A2A2A")
  static let textPrimary = Color(hex: "#FFFFFF")
  static let textSecondary = Color(hex: "#A0A0A0")
  static let borderSubtle = Color(hex: "#3A3A3A")
  static let blackOpacityBackground = Color(hex: "#1e1e1e").opacity(0.95)
  static let thumbnailWidgetBorder = Color(hex: "#3A3A3A")

  // MARK: - Corner Radii
  static let radiusMd: CGFloat = 10
  static let radiusLg: CGFloat = 14

  // MARK: - Sizing
  static let thumbnailWidgetWidth: CGFloat = 160
  static let thumbnailWidgetHeight: CGFloat = 120
  static let previewToolbarHeight: CGFloat = 44

  // MARK: - Shadows
  static let thumbnailShadow = ShadowSpec(blur: 16, y: 4, color: Color.black.opacity(0.4))
  static let previewShadow = ShadowSpec(blur: 64, y: 16, color: Color.black.opacity(0.53))

  // MARK: - Animation
  static let thumbnailDisappearDuration: Double = 0.2

  struct ShadowSpec {
    let blur: CGFloat
    let y: CGFloat
    let color: Color
  }
}

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let r, g, b, a: Double
    switch hex.count {
    case 6:
      (r, g, b, a) = (Double((int >> 16) & 0xFF)/255, Double((int >> 8) & 0xFF)/255, Double(int & 0xFF)/255, 1)
    case 8:
      (r, g, b, a) = (Double((int >> 24) & 0xFF)/255, Double((int >> 16) & 0xFF)/255, Double((int >> 8) & 0xFF)/255, Double(int & 0xFF)/255)
    default:
      (r, g, b, a) = (0, 0, 0, 1)
    }
    self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
  }
}

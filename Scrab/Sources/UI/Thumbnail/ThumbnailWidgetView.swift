import SwiftUI

struct ThumbnailWidgetView: View {
  var store: CaptureStore
  var onItemClick: ((CaptureItem) -> Void)?
  var onItemClose: ((CaptureItem) -> Void)?
  var onItemSave: ((CaptureItem) -> Void)?
  var onSaveAll: (() -> Void)?
  var onDeleteAll: (() -> Void)?

  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text("Captures")
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(DesignTokens.textPrimary)
        Spacer()
        Text("\(store.items.count)")
          .font(.system(size: 11))
          .foregroundStyle(DesignTokens.textSecondary)
      }
      .padding(.horizontal, 12)
      .frame(height: 40)
      .overlay(alignment: .bottom) {
        DesignTokens.borderSubtle
          .frame(height: 1)
      }

      ScrollView(.vertical, showsIndicators: false) {
        let newestFirst = SettingsManager.shared.newestFirst
        let ordered = newestFirst ? store.items.reversed() : store.items
        VStack(spacing: 8) {
          ForEach(
            Array(ordered.enumerated()),
            id: \.element.id
          ) { index, item in
            ThumbnailCardView(
              item: item,
              width: 110,
              height: 80,
              badgeCount: newestFirst ? ordered.count - index : index + 1,
              onClose: { onItemClose?(item) },
              onClick: { onItemClick?(item) },
              onSave: { onItemSave?(item) },
              onDragComplete: nil
            )
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
      }      

      // Bottom toolbar
      HStack {
        Spacer()
        Button(action: { onSaveAll?() }) {
          Image(.download)
            .resizable()
            .frame(width: 14, height: 14)
            .foregroundStyle(.white.opacity(0.8))
        }
        .buttonStyle(.plain)
        
        Spacer()
        
        Button(action: { onDeleteAll?() }) {
          Image(.delete)
            .resizable()
            .frame(width: 14, height: 14)
            .foregroundStyle(.white.opacity(0.8))
        }
        .buttonStyle(.plain)
        Spacer()
      }
      .padding(.vertical, 7)
      .overlay(alignment: .top) {
        DesignTokens.borderSubtle
          .frame(height: 1)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusMd))
    .background(
      DesignTokens.blackOpacityBackground,
      in: RoundedRectangle(cornerRadius: DesignTokens.radiusMd)
    )
    .overlay(
      RoundedRectangle(cornerRadius: DesignTokens.radiusMd)
        .strokeBorder(DesignTokens.thumbnailWidgetBorder, lineWidth: 1.5)
    )
  }
}

import SwiftUI

struct PreviewView: View {
  let item: CaptureItem
  var onCopy: (() -> Void)?
  var onSave: (() -> Void)?
  var onSaveAs: (() -> Void)?
  var onDelete: (() -> Void)?
  var onClose: (() -> Void)?
  
  var body: some View {
    VStack(spacing: 0) {
      // Toolbar
      HStack {
        
        HStack(spacing: 12) {
          // Copy button
          Button(action: { onCopy?() }) {
            Image(.copy)
              .font(.system(size: 14))
              .foregroundStyle(DesignTokens.textSecondary)
              .frame(width: 18, height: 18)
          }
          .buttonStyle(.plain)
          
          // Save button
          Button(action: { onSave?() }) {
            Image(.download)
              .font(.system(size: 14))
              .foregroundStyle(DesignTokens.textSecondary)
              .frame(width: 18, height: 18)
          }
          .buttonStyle(.plain)
          
          // Save As button
          Button(action: { onSaveAs?() }) {
            Image(.folder)
              .font(.system(size: 14))
              .foregroundStyle(DesignTokens.textSecondary)
              .frame(width: 18, height: 18)
          }
          .buttonStyle(.plain)

          // Delete button
          Button(action: { onDelete?() }) {
            Image(.delete)
              .font(.system(size: 14))
              .foregroundStyle(DesignTokens.textSecondary)
              .frame(width: 18, height: 18)
          }
          .buttonStyle(.plain)

          Spacer()
          
          // Close button
          Button(action: { onClose?() }) {
            Image(.close)
              .font(.system(size: 14))
              .foregroundStyle(DesignTokens.textSecondary)
              .frame(width: 18, height: 18)
          }
          .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
      }
      .frame(height: DesignTokens.previewToolbarHeight)
      .background(DesignTokens.blackOpacityBackground)
      
      // Image content
      Image(nsImage: item.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.bgSurface)
    }
    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
    .shadow(
      color: DesignTokens.previewShadow.color,
      radius: DesignTokens.previewShadow.blur / 2,
      y: DesignTokens.previewShadow.y
    )
  }
}

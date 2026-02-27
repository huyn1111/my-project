import SwiftUI

/// 포스트잇 색상을 선택하는 HStack 컴포넌트
struct MemoColorPicker: View {

    @Binding var selectedColor: MemoColor

    var body: some View {
        HStack(spacing: 12) {
            ForEach(MemoColor.allCases, id: \.rawValue) { color in
                colorButton(for: color)
            }
        }
    }

    // MARK: - Subviews

    private func colorButton(for color: MemoColor) -> some View {
        let isSelected = selectedColor == color

        return Button {
            selectedColor = color
        } label: {
            Circle()
                .fill(color.color)
                .frame(width: 32, height: 32)
                .overlay {
                    if isSelected {
                        Circle()
                            .strokeBorder(.primary.opacity(0.6), lineWidth: 2.5)
                    }
                }
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(color.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

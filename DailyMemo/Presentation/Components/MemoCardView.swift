import SwiftUI

/// 포스트잇 형태의 메모 카드 뷰
struct MemoCardView: View {

    let memo: Memo
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteAlert = false

    var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(.plain)
        .onLongPressGesture {
            showDeleteAlert = true
        }
        .alert("메모 삭제", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive, action: onDelete)
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 메모를 삭제하시겠습니까?")
        }
    }

    // MARK: - Subviews

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleView
            contentPreview
            Spacer(minLength: 0)
            dateView
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(memo.memoColor.color, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
    }

    private var titleView: some View {
        Text(memo.title.isEmpty ? "무제" : memo.title)
            .font(.headline)
            .lineLimit(2)
            .foregroundStyle(memo.title.isEmpty ? .secondary : .primary)
    }

    private var contentPreview: some View {
        Text(memo.content)
            .font(.subheadline)
            .lineLimit(3)
            .foregroundStyle(.secondary)
    }

    private var dateView: some View {
        Text(memo.updatedAt.formatted(.relative(presentation: .named)))
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

import SwiftUI
import SwiftData

/// 메모 목록을 포스트잇 그리드로 표시하는 메인 View
struct MemoListView: View {

    @Environment(\.modelContext) private var context

    @Query(sort: \Memo.updatedAt, order: .reverse)
    private var allMemos: [Memo]

    @State private var viewModel = MemoListViewModel()

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            content
                .navigationTitle("DailyMemo")
                .searchable(text: $vm.searchQuery, prompt: "제목 또는 내용 검색")
                .toolbar { toolbarContent }
                .sheet(isPresented: $vm.isAddingMemo) {
                    MemoEditView()
                }
                .sheet(item: $vm.editingMemo) { memo in
                    MemoEditView(memo: memo)
                }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var content: some View {
        let filtered = viewModel.filteredMemos(allMemos)
        if filtered.isEmpty {
            emptyView
        } else {
            memoGrid(filtered)
        }
    }

    private func memoGrid(_ memos: [Memo]) -> some View {
        ScrollView {
            colorFilterBar
                .padding(.horizontal)
                .padding(.top, 4)

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(memos) { memo in
                    MemoCardView(
                        memo: memo,
                        onTap: { viewModel.editingMemo = memo },
                        onDelete: { viewModel.deleteMemo(memo, context: context) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private var colorFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MemoColor.allCases, id: \.rawValue) { color in
                    colorChip(for: color)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func colorChip(for color: MemoColor) -> some View {
        let isSelected = viewModel.selectedColorFilter == color

        return Button {
            viewModel.toggleColorFilter(color)
        } label: {
            HStack(spacing: 4) {
                Circle()
                    .fill(color.color)
                    .frame(width: 12, height: 12)
                Text(color.label)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? color.color : Color(.systemGray6),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(color.label) 필터")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var emptyView: some View {
        let isFiltering = !viewModel.searchQuery.isEmpty || viewModel.selectedColorFilter != nil
        return VStack {
            colorFilterBar
                .padding(.horizontal)
                .padding(.top, 4)

            ContentUnavailableView(
                isFiltering ? "결과 없음" : "메모 없음",
                systemImage: isFiltering ? "magnifyingglass" : "note.text",
                description: Text(
                    isFiltering
                        ? "검색어나 필터를 변경해보세요."
                        : "+ 버튼을 눌러 첫 번째 메모를 작성해보세요."
                )
            )
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.isAddingMemo = true
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .accessibilityLabel("새 메모 작성")
        }
    }
}

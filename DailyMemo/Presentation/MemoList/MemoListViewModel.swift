import Foundation
import Observation
import SwiftData

/// 메모 목록 화면의 상태와 비즘니스 로직을 담당하는 ViewModel
@Observable
@MainActor
final class MemoListViewModel {

    // MARK: - Input

    /// 검색어 (빈 문자열이면 전체 조회)
    var searchQuery: String = ""
    /// 색상 필터 (nil이면 전체 표시)
    var selectedColorFilter: MemoColor?

    // MARK: - Sheet 상태

    /// 새 메모 작성 Sheet 표시 여부
    var isAddingMemo: Bool = false
    /// 수정할 메모 (nil이면 Sheet 닫힐)
    var editingMemo: Memo?

    // MARK: - Filtering

    /// `@Query` 결과를 검색어와 색상 필터로 걸러 반환한다.
    /// - Parameter memos: SwiftData에서 가져온 전체 메모 배열
    /// - Returns: 필터링된 메모 배열
    func filteredMemos(_ memos: [Memo]) -> [Memo] {
        memos.filter { memo in
            matchesColorFilter(memo) && matchesSearchQuery(memo)
        }
    }

    /// 메모를 삭제한다.
    /// - Parameters:
    ///   - memo: 삭제할 메모 객체
    ///   - context: SwiftData ModelContext
    func deleteMemo(_ memo: Memo, context: ModelContext) {
        context.delete(memo)
    }

    /// 색상 필터 칩을 토글한다. 이미 선택된 색상을 탭하면 필터 해제.
    /// - Parameter color: 탭한 색상
    func toggleColorFilter(_ color: MemoColor) {
        selectedColorFilter = (selectedColorFilter == color) ? nil : color
    }

    // MARK: - Private Helpers

    private func matchesColorFilter(_ memo: Memo) -> Bool {
        guard let filter = selectedColorFilter else { return true }
        return memo.colorHex == filter.rawValue
    }

    private func matchesSearchQuery(_ memo: Memo) -> Bool {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }
        return memo.title.localizedCaseInsensitiveContains(searchQuery) ||
               memo.content.localizedCaseInsensitiveContains(searchQuery)
    }
}

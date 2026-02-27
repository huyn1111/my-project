import Foundation
import Observation
import SwiftData

/// 메모 작성/수정 화면의 상태와 비즈니스 로직을 담당하는 ViewModel
@Observable
@MainActor
final class MemoEditViewModel {

    // MARK: - Input

    /// 메모 제목
    var title: String
    /// 메모 본문
    var content: String
    /// 선택된 포스트잇 색상
    var selectedColor: MemoColor

    // MARK: - Output

    /// 수정 모드 여부 (true: 기존 메모 수정, false: 신규 작성)
    let isEditing: Bool
    /// 저장 또는 삭제 실패 시 표시할 에러 메시지
    var errorMessage: String?

    /// 저장 버튼 활성화 조건 — 제목 또는 본문 중 하나 이상 입력 시
    var isSaveEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Private

    private let originalMemo: Memo?

    // MARK: - Init

    /// 신규 메모 작성 초기화
    init() {
        self.title         = ""
        self.content       = ""
        self.selectedColor = .yellow
        self.isEditing     = false
        self.originalMemo  = nil
    }

    /// 기존 메모 수정 초기화
    /// - Parameter memo: 수정할 메모 객체
    init(memo: Memo) {
        self.title         = memo.title
        self.content       = memo.content
        self.selectedColor = memo.memoColor
        self.isEditing     = true
        self.originalMemo  = memo
    }

    // MARK: - Actions

    /// 메모를 저장한다. 신규면 insert, 수정이면 기존 객체 업데이트.
    /// 실패 시 `errorMessage`를 설정하고 반환한다.
    /// - Parameter context: SwiftData ModelContext
    func save(context: ModelContext) {
        guard isSaveEnabled else { return }

        do {
            if let memo = originalMemo {
                memo.title     = title
                memo.content   = content
                memo.colorHex  = selectedColor.rawValue
                memo.updatedAt = Date()
            } else {
                context.insert(Memo(
                    title:    title,
                    content:  content,
                    colorHex: selectedColor.rawValue
                ))
            }
            try context.save()
        } catch {
            errorMessage = "저장에 실패했습니다."
        }
    }

    /// 메모를 삭제한다. 수정 모드일 때만 동작한다.
    /// 실패 시 `errorMessage`를 설정하고 반환한다.
    /// - Parameter context: SwiftData ModelContext
    func delete(context: ModelContext) {
        guard let memo = originalMemo else { return }

        do {
            context.delete(memo)
            try context.save()
        } catch {
            errorMessage = "삭제에 실패했습니다."
        }
    }
}

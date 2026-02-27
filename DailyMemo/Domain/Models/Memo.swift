import SwiftData

// MARK: - MemoColor

/// 포스트잇 배경 색상 팔레트
enum MemoColor: String, CaseIterable, Codable {
    case yellow = "FFF176"
    case pink   = "F48FB1"
    case blue   = "81D4FA"
    case green  = "A5D6A7"
    case purple = "CE93D8"

    /// 접근성 레이블
    var label: String {
        switch self {
        case .yellow: return "노랑"
        case .pink:   return "분홍"
        case .blue:   return "하늘"
        case .green:  return "초록"
        case .purple: return "보라"
        }
    }
}

// MARK: - Memo

/// 메모 데이터 모델 (SwiftData 엔티티)
@Model
final class Memo {
    /// 고유 식별자
    var id: UUID
    /// 제목 (빈 문자열 허용 — "무제" 로 표시)
    var title: String
    /// 본문 내용
    var content: String
    /// 포스트잇 배경 색상 (`MemoColor.rawValue`)
    var colorHex: String
    /// 최초 생성 시각
    var createdAt: Date
    /// 마지막 수정 시각
    var updatedAt: Date

    init(
        title: String = "",
        content: String = "",
        colorHex: String = MemoColor.yellow.rawValue
    ) {
        self.id        = UUID()
        self.title     = title
        self.content   = content
        self.colorHex  = colorHex
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// 저장된 colorHex에 대응하는 `MemoColor`. 매칭 실패 시 `.yellow` 반환.
    var memoColor: MemoColor {
        MemoColor(rawValue: colorHex) ?? .yellow
    }
}


# CLAUDE.md — DailyMemo

Claude Code가 이 프로젝트에서 작업할 때 참조하는 가이드입니다.

## 응답 언어
항상 한국어로 응답한다.

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 앱 이름 | DailyMemo |
| 플랫폼 | iOS 17+ |
| UI 프레임워크 | SwiftUI |
| 영속성 | SwiftData |
| 아키텍처 | MVVM + Clean Architecture |
| 최소 배포 타깃 | iOS 17.0 |

### 핵심 기능
- **메모 CRUD** — 생성 / 조회 / 수정 / 삭제
- **카테고리** — 메모에 카테고리 태그 부여 및 필터링
- **검색** — 제목·본문 전문 검색 (SwiftData `#Predicate` 활용)

---

## 디렉토리 구조

DailyMemo/
├── App/
│   └── DailyMemoApp.swift
├── Domain/
│   ├── Models/
│   │   ├── Memo.swift
│   │   └── Category.swift
│   └── UseCases/
│       ├── MemoUseCaseProtocol.swift
│       └── MemoUseCase.swift
├── Data/
│   └── Repositories/
│       ├── MemoRepositoryProtocol.swift
│       └── MemoRepository.swift
├── Presentation/
│   ├── MemoList/
│   │   ├── MemoListView.swift
│   │   └── MemoListViewModel.swift
│   ├── MemoEdit/
│   │   ├── MemoEditView.swift
│   │   └── MemoEditViewModel.swift
│   └── Components/
└── Resources/
    └── Assets.xcassets

---

## 아키텍처 규칙

레이어 의존성: Presentation → Domain ← Data

- Presentation: ViewModel은 UseCase 프로토콜에만 의존
- Domain: 순수 Swift — UIKit·SwiftUI·SwiftData import 없음
- Data: Repository가 SwiftData ModelContext를 소유
- @Observable 매크로 사용 (iOS 17+)
- @MainActor 명시 필수

---

## 코딩 컨벤션

- 모든 public/internal API에 /// 필수
- 강제 언래핑(!) 사용 금지
- 커밋에 print() 포함 금지
- main 브랜치 직접 커밋 금지
- Domain 레이어에서 SwiftUI·SwiftData import 금지
- ModelContext는 Environment로 주입, 직접 생성 금지

---

## 빌드 & 테스트

swift build
swift test
swiftlint

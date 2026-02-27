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

```
DailyMemo/
├── DailyMemoApp.swift
├── Domain/Models/Memo.swift
├── Presentation/
│   ├── MemoList/
│   ├── MemoEdit/
│   ├── Extensions/Color+Hex.swift
│   └── Components/
└── DailyMemoTests/
```

---

## 코딩 컨벤션

| 규칙 | 세부 사항 |
|------|----------|
| 문서 주석 | 모든 `public` / `internal` API에 `///` 필수 |
| 강제 언래핑 | `!` 사용 금지 |
| print 디버깅 | 커밋에 `print()` 포함 금지 |
| 브랜치 | `main`에 직접 커밋 금지 |

## DO NOT
- `main` 브랜치에 직접 커밋하지 않는다
- 강제 언래핑(`!`) 사용하지 않는다
- `print()` 를 커밋에 포함하지 않는다
- ViewModel에서 SwiftData `@Query` 를 사용하지 않는다
- Domain 레이어에서 SwiftUI를 import하지 않는다

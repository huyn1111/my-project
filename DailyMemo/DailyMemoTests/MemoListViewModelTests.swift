import Testing
import SwiftData
@testable import DailyMemo

@Suite("MemoListViewModel 테스트")
@MainActor
struct MemoListViewModelTests {

    private let sut: MemoListViewModel
    private let context: ModelContext

    init() throws {
        let container = try ModelContainer(
            for: Memo.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
        sut = MemoListViewModel()
    }

    // MARK: - 초기 상태

    @Test("초기 searchQuery 가 빈 문자열")
    func init_searchQuery() {
        #expect(sut.searchQuery == "")
    }

    @Test("초기 selectedColorFilter 가 nil")
    func init_selectedColorFilter() {
        #expect(sut.selectedColorFilter == nil)
    }

    @Test("초기 Sheet 상태 — isAddingMemo false, editingMemo nil")
    func init_sheetState() {
        #expect(sut.isAddingMemo == false)
        #expect(sut.editingMemo == nil)
    }

    // MARK: - filteredMemos — 검색어

    @Test("검색어 없으면 전체 메모 반환")
    func filteredMemos_noQuery_returnsAll() {
        let memos = makeMemos(["A", "B", "C"])
        #expect(sut.filteredMemos(memos).count == 3)
    }

    @Test("빈 배열 입력 시 빈 배열 반환")
    func filteredMemos_emptyInput_returnsEmpty() {
        #expect(sut.filteredMemos([]).isEmpty)
    }

    @Test("제목으로 검색하면 일치하는 메모만 반환")
    func filteredMemos_titleSearch() {
        let memos = makeMemos(["사과 주스", "바나나", "사과 케이크"])
        sut.searchQuery = "사과"
        #expect(sut.filteredMemos(memos).count == 2)
    }

    @Test("본문으로 검색하면 일치하는 메모만 반환")
    func filteredMemos_contentSearch() {
        let a = Memo(title: "제목1", content: "맑은 날씨")
        let b = Memo(title: "제목2", content: "비가 온다")
        sut.searchQuery = "맑은"
        let result = sut.filteredMemos([a, b])
        #expect(result.count == 1)
        #expect(result.first?.title == "제목1")
    }

    @Test("검색은 대소문자를 무시한다")
    func filteredMemos_caseInsensitive() {
        let memos = [Memo(title: "Hello World")]
        sut.searchQuery = "hello"
        #expect(sut.filteredMemos(memos).count == 1)
    }

    @Test("검색 결과 없으면 빈 배열 반환")
    func filteredMemos_noResults_returnsEmpty() {
        let memos = makeMemos(["사과", "바나나"])
        sut.searchQuery = "포도"
        #expect(sut.filteredMemos(memos).isEmpty)
    }

    @Test("공백만 있는 검색어는 전체 반환")
    func filteredMemos_whitespaceQuery_returnsAll() {
        let memos = makeMemos(["A", "B"])
        sut.searchQuery = "   "
        #expect(sut.filteredMemos(memos).count == 2)
    }

    // MARK: - filteredMemos — 색상 필터

    @Test("색상 필터 적용 시 해당 색상 메모만 반환")
    func filteredMemos_colorFilter_returnsMatching() {
        let memos = [
            Memo(title: "노랑", colorHex: MemoColor.yellow.rawValue),
            Memo(title: "분홍", colorHex: MemoColor.pink.rawValue),
            Memo(title: "파랑", colorHex: MemoColor.blue.rawValue),
        ]
        sut.selectedColorFilter = .yellow
        let result = sut.filteredMemos(memos)
        #expect(result.count == 1)
        #expect(result.first?.title == "노랑")
    }

    @Test("색상 필터 nil 이면 전체 메모 반환")
    func filteredMemos_nilColorFilter_returnsAll() {
        let memos = [
            Memo(title: "A", colorHex: MemoColor.yellow.rawValue),
            Memo(title: "B", colorHex: MemoColor.green.rawValue),
        ]
        sut.selectedColorFilter = nil
        #expect(sut.filteredMemos(memos).count == 2)
    }

    @Test("검색어 + 색상 필터 동시 적용")
    func filteredMemos_combinedFilters() {
        let memos = [
            Memo(title: "노랑 메모",  colorHex: MemoColor.yellow.rawValue),
            Memo(title: "파랑 메모",  colorHex: MemoColor.blue.rawValue),
            Memo(title: "노랑 다른것", colorHex: MemoColor.yellow.rawValue),
        ]
        sut.selectedColorFilter = .yellow
        sut.searchQuery = "메모"
        let result = sut.filteredMemos(memos)
        #expect(result.count == 1)
        #expect(result.first?.title == "노랑 메모")
    }

    // MARK: - toggleColorFilter

    @Test("색상 선택 시 selectedColorFilter 에 설정됨")
    func toggleColorFilter_setsColor() {
        sut.toggleColorFilter(.blue)
        #expect(sut.selectedColorFilter == .blue)
    }

    @Test("선택된 색상 재탭 시 nil 로 해제됨")
    func toggleColorFilter_retap_setsNil() {
        sut.toggleColorFilter(.blue)
        sut.toggleColorFilter(.blue)
        #expect(sut.selectedColorFilter == nil)
    }

    @Test("다른 색상 탭 시 새 색상으로 변경됨")
    func toggleColorFilter_differentColor_changes() {
        sut.toggleColorFilter(.blue)
        sut.toggleColorFilter(.green)
        #expect(sut.selectedColorFilter == .green)
    }

    @Test("MemoColor 전체 케이스 순차 선택 가능")
    func toggleColorFilter_allCases() {
        for color in MemoColor.allCases {
            sut.selectedColorFilter = nil
            sut.toggleColorFilter(color)
            #expect(sut.selectedColorFilter == color)
        }
    }

    // MARK: - deleteMemo

    @Test("deleteMemo 호출 후 해당 메모가 fetch 결과에서 사라짐")
    func deleteMemo_removesFromContext() throws {
        let memo = Memo(title: "삭제 대상")
        context.insert(memo)
        try context.save()

        sut.deleteMemo(memo, context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.isEmpty)
    }

    @Test("deleteMemo 는 지정한 메모만 삭제하고 나머지는 유지됨")
    func deleteMemo_keepsOthers() throws {
        let target = Memo(title: "삭제")
        let other  = Memo(title: "유지")
        context.insert(target)
        context.insert(other)
        try context.save()

        sut.deleteMemo(target, context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.count == 1)
        #expect(results.first?.title == "유지")
    }

    @Test("여러 메모 중 특정 메모만 삭제됨")
    func deleteMemo_specificAmongMany() throws {
        let memos = (1...3).map { Memo(title: "메모 \($0)") }
        memos.forEach { context.insert($0) }
        try context.save()

        sut.deleteMemo(memos[1], context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.count == 2)
        #expect(!results.contains { $0.title == "메모 2" })
    }

    // MARK: - Helpers

    private func makeMemos(_ titles: [String]) -> [Memo] {
        titles.map { Memo(title: $0, content: "") }
    }
}

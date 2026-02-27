import Testing
import SwiftData
@testable import DailyMemo

@Suite("MemoEditViewModel 테스트")
@MainActor
struct MemoEditViewModelTests {

    private let context: ModelContext

    init() throws {
        let container = try ModelContainer(
            for: Memo.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
    }

    // MARK: - init() 신규 작성

    @Test("신규 초기화: title 과 content 가 빈 문자열")
    func init_신규_빈문자열초기화() {
        let sut = MemoEditViewModel()
        #expect(sut.title == "")
        #expect(sut.content == "")
    }

    @Test("신규 초기화: 기본 색상이 yellow")
    func init_신규_기본색상yellow() {
        let sut = MemoEditViewModel()
        #expect(sut.selectedColor == .yellow)
    }

    @Test("신규 초기화: isEditing 이 false, errorMessage 가 nil")
    func init_신규_isEditing과errorMessage() {
        let sut = MemoEditViewModel()
        #expect(sut.isEditing == false)
        #expect(sut.errorMessage == nil)
    }

    // MARK: - init(memo:) 수정 모드

    @Test("수정 초기화: 기존 메모의 title, content 로 채워짐")
    func init_수정_기존메모값으로초기화() {
        let memo = Memo(title: "기존 제목", content: "기존 본문")
        context.insert(memo)
        let sut = MemoEditViewModel(memo: memo)
        #expect(sut.title == "기존 제목")
        #expect(sut.content == "기존 본문")
    }

    @Test("수정 초기화: isEditing 이 true")
    func init_수정_isEditingTrue() {
        let memo = Memo(title: "메모")
        let sut = MemoEditViewModel(memo: memo)
        #expect(sut.isEditing == true)
    }

    @Test("수정 초기화: 메모의 색상으로 채워짐")
    func init_수정_색상이메모색상으로초기화() {
        let memo = Memo(colorHex: MemoColor.purple.rawValue)
        let sut = MemoEditViewModel(memo: memo)
        #expect(sut.selectedColor == .purple)
    }

    // MARK: - isSaveEnabled

    @Test("제목만 있으면 저장 활성화")
    func isSaveEnabled_제목만있으면true() {
        let sut = MemoEditViewModel()
        sut.title = "제목"
        #expect(sut.isSaveEnabled == true)
    }

    @Test("본문만 있으면 저장 활성화")
    func isSaveEnabled_본문만있으면true() {
        let sut = MemoEditViewModel()
        sut.content = "본문"
        #expect(sut.isSaveEnabled == true)
    }

    @Test("제목과 본문 모두 비어 있으면 저장 비활성화")
    func isSaveEnabled_모두비어있으면false() {
        let sut = MemoEditViewModel()
        #expect(sut.isSaveEnabled == false)
    }

    @Test("공백·개행만 있으면 저장 비활성화")
    func isSaveEnabled_공백개행만있으면false() {
        let sut = MemoEditViewModel()
        sut.title   = "   "
        sut.content = "\n\t"
        #expect(sut.isSaveEnabled == false)
    }

    @Test("제목과 본문 모두 있으면 저장 활성화")
    func isSaveEnabled_모두있으면true() {
        let sut = MemoEditViewModel()
        sut.title   = "제목"
        sut.content = "본문"
        #expect(sut.isSaveEnabled == true)
    }

    // MARK: - save — 신규

    @Test("신규 저장 후 컨텍스트에서 fetch 됨")
    func save_신규_컨텍스트에추가됨() throws {
        let sut = MemoEditViewModel()
        sut.title   = "새 메모"
        sut.content = "내용"
        sut.save(context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.count == 1)
        #expect(results.first?.title == "새 메모")
    }

    @Test("신규 저장 시 선택 색상이 저장됨")
    func save_신규_선택색상저장됨() throws {
        let sut = MemoEditViewModel()
        sut.title         = "메모"
        sut.selectedColor = .blue
        sut.save(context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.first?.colorHex == MemoColor.blue.rawValue)
    }

    @Test("isSaveEnabled 가 false 이면 저장되지 않음")
    func save_신규_isSaveEnabledFalse이면저장안됨() throws {
        let sut = MemoEditViewModel()   // title, content 모두 비어 있음
        sut.save(context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.isEmpty)
    }

    @Test("신규 저장 성공 시 errorMessage 가 nil")
    func save_신규_성공시errorMessageNil() {
        let sut = MemoEditViewModel()
        sut.title = "메모"
        sut.save(context: context)
        #expect(sut.errorMessage == nil)
    }

    // MARK: - save — 수정

    @Test("수정 저장 시 기존 메모의 title, content 가 업데이트됨")
    func save_수정_제목내용업데이트() {
        let memo = Memo(title: "원본", content: "원본 내용")
        context.insert(memo)

        let sut = MemoEditViewModel(memo: memo)
        sut.title   = "수정됨"
        sut.content = "수정된 내용"
        sut.save(context: context)

        #expect(memo.title   == "수정됨")
        #expect(memo.content == "수정된 내용")
    }

    @Test("수정 저장 시 색상이 업데이트됨")
    func save_수정_색상업데이트() {
        let memo = Memo(colorHex: MemoColor.yellow.rawValue)
        context.insert(memo)

        let sut = MemoEditViewModel(memo: memo)
        sut.title         = "메모"
        sut.selectedColor = .purple
        sut.save(context: context)

        #expect(memo.colorHex == MemoColor.purple.rawValue)
    }

    @Test("수정 저장 시 updatedAt 이 저장 이전 시각 이상으로 갱신됨")
    func save_수정_updatedAt갱신됨() {
        let before = Date()
        let memo = Memo(title: "테스트")
        context.insert(memo)

        let sut = MemoEditViewModel(memo: memo)
        sut.title = "변경"
        sut.save(context: context)

        #expect(memo.updatedAt >= before)
    }

    @Test("수정 저장 시 새 메모가 추가되지 않음")
    func save_수정_새메모추가안됨() throws {
        let memo = Memo(title: "기존")
        context.insert(memo)

        let sut = MemoEditViewModel(memo: memo)
        sut.title = "수정"
        sut.save(context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.count == 1)
    }

    // MARK: - delete

    @Test("수정 모드에서 delete 호출 시 메모가 삭제됨")
    func delete_수정모드에서삭제됨() throws {
        let memo = Memo(title: "삭제 대상")
        context.insert(memo)

        let sut = MemoEditViewModel(memo: memo)
        sut.delete(context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.isEmpty)
    }

    @Test("신규 작성 모드에서 delete 호출 시 아무것도 삭제되지 않음")
    func delete_신규모드에서는아무것도삭제안됨() throws {
        let memo = Memo(title: "유지됨")
        context.insert(memo)

        let sut = MemoEditViewModel()   // originalMemo = nil
        sut.delete(context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.count == 1)
    }

    @Test("delete 성공 시 errorMessage 가 nil")
    func delete_성공시errorMessageNil() {
        let memo = Memo(title: "삭제")
        context.insert(memo)

        let sut = MemoEditViewModel(memo: memo)
        sut.delete(context: context)

        #expect(sut.errorMessage == nil)
    }

    @Test("delete 는 지정한 메모만 삭제하고 나머지는 유지됨")
    func delete_지정메모만삭제() throws {
        let target = Memo(title: "삭제 대상")
        let other  = Memo(title: "유지됨")
        context.insert(target)
        context.insert(other)

        let sut = MemoEditViewModel(memo: target)
        sut.delete(context: context)

        let results = try context.fetch(FetchDescriptor<Memo>())
        #expect(results.count == 1)
        #expect(results.first?.title == "유지됨")
    }
}

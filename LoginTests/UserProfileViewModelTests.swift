import XCTest
@testable import YourApp  // TODO: 앱 모듈명으로 교체

// MARK: - Mock

final class MockUserProfileUseCase: UserProfileUseCaseProtocol {
    var result: Result<UserProfile, Error> = .success(
        UserProfile(name: "홍길동", email: "hong@example.com", phone: "010-1234-5678")
    )
    var fetchCallCount = 0
    var fetchDelay: Duration = .zero

    func fetchProfile() async throws -> UserProfile {
        fetchCallCount += 1
        if fetchDelay > .zero {
            try await Task.sleep(for: fetchDelay)
        }
        return try result.get()
    }
}

// MARK: - Test Error

private enum TestError: LocalizedError {
    case network
    var errorDescription: String? { "네트워크 오류" }
}

// MARK: - Tests

@MainActor
final class UserProfileViewModelTests: XCTestCase {

    private var sut: UserProfileViewModel!
    private var mockUseCase: MockUserProfileUseCase!

    override func setUp() {
        super.setUp()
        mockUseCase = MockUserProfileUseCase()
        sut = UserProfileViewModel(useCase: mockUseCase)
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }

    // MARK: - 초기 상태

    func test_초기상태_프로필이빈값() {
        XCTAssertEqual(sut.profile.name, "")
        XCTAssertEqual(sut.profile.email, "")
        XCTAssertEqual(sut.profile.phone, "")
        XCTAssertNil(sut.profile.profileImageName)
    }

    func test_초기상태_로딩및에러없음() {
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - loadProfile 성공

    func test_loadProfile_성공시프로필업데이트() async {
        await sut.loadProfile()

        XCTAssertEqual(sut.profile.name, "홍길동")
        XCTAssertEqual(sut.profile.email, "hong@example.com")
        XCTAssertEqual(sut.profile.phone, "010-1234-5678")
    }

    func test_loadProfile_성공시errorMessage는nil() async {
        await sut.loadProfile()

        XCTAssertNil(sut.errorMessage)
    }

    func test_loadProfile_완료후isLoading이false() async {
        await sut.loadProfile()

        XCTAssertFalse(sut.isLoading)
    }

    func test_loadProfile_useCase가정확히1회호출됨() async {
        await sut.loadProfile()

        XCTAssertEqual(mockUseCase.fetchCallCount, 1)
    }

    // MARK: - loadProfile 실패

    func test_loadProfile_실패시errorMessage설정() async {
        mockUseCase.result = .failure(TestError.network)

        await sut.loadProfile()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, TestError.network.errorDescription)
    }

    func test_loadProfile_실패시프로필이변경되지않음() async {
        mockUseCase.result = .failure(TestError.network)

        await sut.loadProfile()

        XCTAssertEqual(sut.profile.name, "")
    }

    func test_loadProfile_실패후isLoading이false() async {
        mockUseCase.result = .failure(TestError.network)

        await sut.loadProfile()

        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Task 취소

    func test_loadProfile_취소시프로필이변경되지않음() async {
        mockUseCase.fetchDelay = .milliseconds(100)

        let task = Task { await self.sut.loadProfile() }
        task.cancel()
        await task.value

        XCTAssertEqual(sut.profile.name, "")
    }

    func test_loadProfile_취소시isLoading이false() async {
        mockUseCase.fetchDelay = .milliseconds(100)

        let task = Task { await self.sut.loadProfile() }
        task.cancel()
        await task.value

        XCTAssertFalse(sut.isLoading)
    }

    func test_loadProfile_취소시errorMessage없음() async {
        mockUseCase.fetchDelay = .milliseconds(100)

        let task = Task { await self.sut.loadProfile() }
        task.cancel()
        await task.value

        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - 연속 호출

    func test_loadProfile_연속호출시useCase두번호출됨() async {
        await sut.loadProfile()
        await sut.loadProfile()

        XCTAssertEqual(mockUseCase.fetchCallCount, 2)
    }

    func test_loadProfile_두번째호출시이전에러초기화() async {
        mockUseCase.result = .failure(TestError.network)
        await sut.loadProfile()

        mockUseCase.result = .success(
            UserProfile(name: "홍길동", email: "hong@example.com", phone: "010-1234-5678")
        )
        await sut.loadProfile()

        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.profile.name, "홍길동")
    }
}

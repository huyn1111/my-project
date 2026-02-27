import SwiftUI

// MARK: - Model

/// 사용자 프로필 데이터 모델
struct UserProfile {
    var name: String
    var email: String
    var phone: String
    var profileImageName: String?
}

// MARK: - Use Case Protocol

/// 프로필 데이터를 가져오는 UseCase 프로토콜
protocol UserProfileUseCaseProtocol {
    func fetchProfile() async throws -> UserProfile
}

/// 기본 UseCase 구현체
final class DefaultUserProfileUseCase: UserProfileUseCaseProtocol {
    func fetchProfile() async throws -> UserProfile {
        try await Task.sleep(for: .seconds(1))
        return UserProfile(
            name: "홍길동",
            email: "hong@example.com",
            phone: "010-1234-5678",
            profileImageName: nil
        )
    }
}

// MARK: - ViewModel

/// 사용자 프로필 화면의 비즈니스 로직을 담당하는 ViewModel
@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let useCase: UserProfileUseCaseProtocol

    init(useCase: UserProfileUseCaseProtocol = DefaultUserProfileUseCase()) {
        self.profile = UserProfile(name: "", email: "", phone: "")
        self.useCase = useCase
    }

    /// 프로필 데이터를 불러옵니다.
    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            profile = try await useCase.fetchProfile()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - View

/// 사용자 프로필을 표시하는 View
struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("프로필")
                .task { await viewModel.loadProfile() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            profileContent
        }
    }

    private var profileContent: some View {
        List {
            profileImageSection
            infoSection
        }
        .listStyle(.insetGrouped)
    }

    private var profileImageSection: some View {
        Section {
            HStack {
                Spacer()
                ProfileImageView(imageName: viewModel.profile.profileImageName)
                Spacer()
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }

    private var infoSection: some View {
        Section("기본 정보") {
            ProfileInfoRow(label: "이름", value: viewModel.profile.name, icon: "person.fill")
            ProfileInfoRow(label: "이메일", value: viewModel.profile.email, icon: "envelope.fill")
            ProfileInfoRow(label: "전화번호", value: viewModel.profile.phone, icon: "phone.fill")
        }
    }
}

// MARK: - Profile Image View

/// 프로필 이미지를 표시하는 View
private struct ProfileImageView: View {
    let imageName: String?

    private let size: CGFloat = 100

    var body: some View {
        Group {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Info Row View

/// 프로필 정보의 각 행을 표시하는 View
private struct ProfileInfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value.isEmpty ? "-" : value)
                    .font(.body)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    UserProfileView()
}

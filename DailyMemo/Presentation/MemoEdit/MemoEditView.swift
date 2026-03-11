import SwiftUI
import SwiftData

/// 메모를 작성하거나 수정하는 Sheet View
struct MemoEditView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: MemoEditViewModel

    /// 신규 메모 작성 시 초기화
    init() {
        _viewModel = State(initialValue: MemoEditViewModel())
    }

    /// 기존 메모 수정 시 초기화
    /// - Parameter memo: 수정할 메모 객체
    init(memo: Memo) {
        _viewModel = State(initialValue: MemoEditViewModel(memo: memo))
    }

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    colorSection($vm.selectedColor)
                    inputSection(title: $vm.title, content: $vm.content)
                }
                .padding()
            }
            .background(viewModel.selectedColor.color.opacity(0.25))
            .navigationTitle(viewModel.isEditing ? "메모 수정" : "새 메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .alert("오류", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("확인") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Subviews

    private func colorSection(_ selectedColor: Binding<MemoColor>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("색상")
                .font(.caption)
                .foregroundStyle(.secondary)
            MemoColorPicker(selectedColor: selectedColor)
        }
    }

    private func inputSection(title: Binding<String>, content: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("제목", text: title)
                .font(.title3.bold())

            Rectangle()
                .fill(.primary.opacity(0.15))
                .frame(height: 1)

            TextEditor(text: content)
                .font(.body)
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
        }
        .padding()
        .background(viewModel.selectedColor.color, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("취소") { dismiss() }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("저장") {
                viewModel.save(context: context)
                if viewModel.errorMessage == nil {
                    dismiss()
                }
            }
            .disabled(!viewModel.isSaveEnabled)
            .fontWeight(.semibold)
        }

        if viewModel.isEditing {
            ToolbarItem(placement: .bottomBar) {
                Button(role: .destructive) {
                    viewModel.delete(context: context)
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                } label: {
                    Label("메모 삭제", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

import Core
import SwiftUI

public struct AddEditTaskView: View {
    @StateObject private var viewModel: AddEditTaskViewModel
    @State private var hasDueDate: Bool
    @State private var newSubtaskTitle = ""

    private let onSave: (TodoItem) -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: @autoclosure @escaping () -> AddEditTaskViewModel,
        onSave: @escaping (TodoItem) -> Void,
        onCancel: @escaping () -> Void
    ) {
        let vm = viewModel()
        _viewModel = StateObject(wrappedValue: vm)
        _hasDueDate = State(initialValue: vm.dueDate != nil)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TFSpacing.lg) {
                titleField
                descriptionField
                priorityPicker
                dueDateSection
                subtasksSection

                if let validationError = viewModel.validationError {
                    Text(validationError)
                        .font(TFTypography.label())
                        .foregroundStyle(TFColor.terracotta)
                }
            }
            .padding(TFSpacing.md)
        }
        .background(TFColor.background.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isEditing ? "Save" : "Add") {
                    Task {
                        if let saved = await viewModel.save() {
                            onSave(saved)
                        }
                    }
                }
                .disabled(viewModel.isSaving)
                .accessibilityIdentifier("addEditTask.save")
            }
        }
    }

    private var titleField: some View {
        TextField("Title", text: $viewModel.title)
            .font(TFTypography.taskTitle())
            .accessibilityIdentifier("addEditTask.titleField")
    }

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xs) {
            SectionLabel(title: "Description")
            TextField("Add a description", text: $viewModel.description, axis: .vertical)
                .font(TFTypography.body())
                .lineLimit(3...6)
        }
    }

    private var priorityPicker: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xs) {
            SectionLabel(title: "Priority")
            Picker("Priority", selection: $viewModel.priority) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    Text(priority.rawValue.capitalized).tag(priority)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xs) {
            Toggle("Due date", isOn: $hasDueDate)
                .font(TFTypography.body())
                .onChange(of: hasDueDate) { _, isOn in
                    viewModel.dueDate = isOn ? (viewModel.dueDate ?? Date()) : nil
                }

            if hasDueDate {
                DatePicker(
                    "Due date",
                    selection: Binding(
                        get: { viewModel.dueDate ?? Date() },
                        set: { viewModel.dueDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .labelsHidden()
            }
        }
    }

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            SectionLabel(title: "Subtasks")

            ForEach(viewModel.subtasks) { subtask in
                HStack {
                    Text(subtask.title)
                        .font(TFTypography.body())
                    Spacer()
                    Button {
                        viewModel.removeSubtask(id: subtask.id)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(TFColor.ink.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(subtask.title)")
                }
            }

            HStack {
                TextField("Add subtask", text: $newSubtaskTitle)
                    .font(TFTypography.body())
                    .accessibilityIdentifier("addEditTask.subtaskField")
                Button("Add") {
                    viewModel.addSubtask(title: newSubtaskTitle)
                    newSubtaskTitle = ""
                }
                .disabled(newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("addEditTask.addSubtask")
            }
        }
    }
}

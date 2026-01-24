import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TodoViewModel
    
    @State private var title = ""
    @State private var priority: TodoPriority = .medium
    @State private var category: TodoCategory = .personal
    @State private var estimatedHours = 0
    @State private var estimatedMinutes = 30
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var isRepeating = false
    @State private var selectedDays: Set<Int> = []
    
    private let hours = Array(0...23)
    private let minutes = [0, 15, 30, 45]
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        NavigationStack {
            Form {
                // 제목
                Section("할 일") {
                    TextField("무엇을 해야 하나요?", text: $title)
                        .font(.body)
                }
                
                // 우선순위
                Section("우선순위") {
                    Picker("우선순위", selection: $priority) {
                        ForEach(TodoPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priorityColor(priority))
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 카테고리
                Section("카테고리") {
                    Picker("카테고리", selection: $category) {
                        ForEach(TodoCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // 예상 소모 시간
                Section("예상 소모 시간") {
                    HStack {
                        Picker("시간", selection: $estimatedHours) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour)시간").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        
                        Picker("분", selection: $estimatedMinutes) {
                            ForEach(minutes, id: \.self) { minute in
                                Text("\(minute)분").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 120)
                }
                
                // 마감 시간
                Section {
                    Toggle("마감시간 설정", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(
                            "마감시간",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                    }
                } header: {
                    Text("마감시간")
                } footer: {
                    if hasDueDate {
                        let timeUntil = dueDate.timeIntervalSinceNow
                        if timeUntil < 0 {
                            Text("⚠️ 마감시간이 이미 지났습니다")
                                .foregroundColor(.red)
                        } else if timeUntil < 86400 {
                            Text("⏰ 24시간 이내에 마감됩니다")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // 반복 주기
                Section {
                    Toggle("반복 설정", isOn: $isRepeating)
                    
                    if isRepeating {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("반복할 요일을 선택하세요")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                ForEach(0..<7) { index in
                                    DayButton(
                                        day: weekdays[index],
                                        isSelected: selectedDays.contains(index)
                                    ) {
                                        if selectedDays.contains(index) {
                                            selectedDays.remove(index)
                                        } else {
                                            selectedDays.insert(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("반복")
                } footer: {
                    if isRepeating && !selectedDays.isEmpty {
                        Text("매주 \(selectedDays.sorted().map { weekdays[$0] }.joined(separator: ", "))에 반복됩니다")
                    }
                }
            }
            .navigationTitle("새로운 할 일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        addTodo()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func priorityColor(_ priority: TodoPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    private func addTodo() {
        let totalMinutes = estimatedHours * 60 + estimatedMinutes
        
        let newTodo = TodoItem(
            title: title.trimmingCharacters(in: .whitespaces),
            priority: priority,
            category: category,
            estimatedMinutes: totalMinutes,
            dueDate: hasDueDate ? dueDate : nil,
            repeatCycle: RepeatCycle(
                isRepeating: isRepeating,
                selectedDays: selectedDays
            )
        )
        
        viewModel.addTodo(newTodo)
        dismiss()
    }
}

struct DayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(20)
        }
    }
}

#Preview {
    AddTodoView(viewModel: TodoViewModel())
}

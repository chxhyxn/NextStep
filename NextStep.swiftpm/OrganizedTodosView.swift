import SwiftUI

struct OrganizedTodosView: View {
    @Bindable var viewModel: TodoViewModel
    @State private var showingAddTodo = false
    
    var body: some View {
        ZStack {
            // 배경
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 헤더
                HStack {
                    VStack(alignment: .leading) {
                        Text("정리된 할 일")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(viewModel.incompleteTodos.count)개의 할 일")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 다시 흩어지기 버튼
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            viewModel.unorganize()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .padding(10)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                // 할 일 목록
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // 미완료 할 일들
                        ForEach(viewModel.incompleteTodos) { todo in
                            OrganizedTodoRow(
                                todo: todo,
                                onToggle: { viewModel.toggleComplete(todo) },
                                onDelete: { viewModel.deleteTodo(todo) }
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                        }
                        
                        // 완료된 할 일들
                        if !viewModel.completedTodos.isEmpty {
                            Section {
                                DisclosureGroup("완료된 할 일 (\(viewModel.completedTodos.count)개)") {
                                    ForEach(viewModel.completedTodos) { todo in
                                        OrganizedTodoRow(
                                            todo: todo,
                                            onToggle: { viewModel.toggleComplete(todo) },
                                            onDelete: { viewModel.deleteTodo(todo) }
                                        )
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding()
                }
                
                // 하단 추가 버튼
                Button(action: {
                    showingAddTodo = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("할 일 추가")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTodoView(viewModel: viewModel)
        }
    }
}

struct OrganizedTodoRow: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // 완료 체크박스
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? .green : priorityColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // 제목과 카테고리
                HStack {
                    Text(todo.title)
                        .font(.headline)
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: todo.category.icon)
                        .font(.caption)
                        .foregroundColor(priorityColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // 메타 정보
                HStack(spacing: 12) {
                    // 우선순위
                    Label(todo.priority.rawValue, systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(priorityColor)
                    
                    // 예상 시간
                    Label(todo.estimatedTimeString, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 마감시간
                    if let dueDateString = todo.dueDateString {
                        Label(dueDateString, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(isDueSoon ? .red : .secondary)
                    }
                    
                    // 반복
                    if todo.repeatCycle.isRepeating {
                        Label(todo.repeatCycle.dayNames.joined(separator: ","), systemImage: "repeat")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .lineLimit(1)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: priorityColor.opacity(0.2), radius: 5)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
    
    private var priorityColor: Color {
        switch todo.priority {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    private var isDueSoon: Bool {
        guard let dueDate = todo.dueDate else { return false }
        return dueDate.timeIntervalSinceNow < 86400 // 24시간 이내
    }
}

#Preview {
    OrganizedTodosView(viewModel: TodoViewModel())
}

import Foundation
import SwiftUI

@Observable
class TodoViewModel {
    var todos: [TodoItem] = []
    var isOrganized: Bool = false
    
    init() {
        loadTodos()
        // 샘플 데이터 추가 (첫 실행시)
        if todos.isEmpty {
            addSampleData()
        }
    }
    
    // MARK: - CRUD Operations
    
    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
        saveTodos()
    }
    
    func updateTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveTodos()
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
    }
    
    func toggleComplete(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            saveTodos()
        }
    }
    
    // MARK: - Organization Logic
    
    func organizeTodos() {
        // ADHD 환자를 위한 스마트 정리 로직
        todos.sort { todo1, todo2 in
            // 1. 완료된 항목은 맨 아래로
            if todo1.isCompleted != todo2.isCompleted {
                return !todo1.isCompleted
            }
            
            // 2. 긴급도 비교 (마감시간이 임박한 것 우선)
            if let due1 = todo1.dueDate, let due2 = todo2.dueDate {
                let now = Date()
                let timeUntil1 = due1.timeIntervalSince(now)
                let timeUntil2 = due2.timeIntervalSince(now)
                
                // 마감시간이 24시간 이내인 경우 최우선
                if timeUntil1 < 86400 && timeUntil2 >= 86400 {
                    return true
                }
                if timeUntil2 < 86400 && timeUntil1 >= 86400 {
                    return false
                }
                
                if timeUntil1 != timeUntil2 {
                    return timeUntil1 < timeUntil2
                }
            } else if todo1.dueDate != nil {
                return true
            } else if todo2.dueDate != nil {
                return false
            }
            
            // 3. 우선순위 비교
            let priorityOrder: [TodoPriority] = [.urgent, .high, .medium, .low]
            let priority1Index = priorityOrder.firstIndex(of: todo1.priority) ?? priorityOrder.count
            let priority2Index = priorityOrder.firstIndex(of: todo2.priority) ?? priorityOrder.count
            
            if priority1Index != priority2Index {
                return priority1Index < priority2Index
            }
            
            // 4. 예상 소모시간이 짧은 것 우선 (빠른 성취감)
            if todo1.estimatedMinutes != todo2.estimatedMinutes {
                return todo1.estimatedMinutes < todo2.estimatedMinutes
            }
            
            // 5. 생성 시간 순
            return todo1.createdAt < todo2.createdAt
        }
        
        isOrganized = true
        saveTodos()
    }
    
    func unorganize() {
        isOrganized = false
    }
    
    // MARK: - Filtering
    
    var incompleteTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }
    
    var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }
    
    func todosByCategory(_ category: TodoCategory) -> [TodoItem] {
        todos.filter { $0.category == category && !$0.isCompleted }
    }
    
    // MARK: - Persistence
    
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "todos")
        }
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: "todos"),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }
    
    // MARK: - Sample Data
    
    private func addSampleData() {
        let sampleTodos = [
            TodoItem(
                title: "병원 예약하기",
                priority: .high,
                category: .health,
                estimatedMinutes: 15,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
            ),
            TodoItem(
                title: "프로젝트 제안서 작성",
                priority: .urgent,
                category: .work,
                estimatedMinutes: 120,
                dueDate: Calendar.current.date(byAdding: .hour, value: 6, to: Date())
            ),
            TodoItem(
                title: "운동하기",
                priority: .medium,
                category: .health,
                estimatedMinutes: 30,
                repeatCycle: RepeatCycle(isRepeating: true, selectedDays: [1, 3, 5])
            ),
            TodoItem(
                title: "책 읽기",
                priority: .low,
                category: .learning,
                estimatedMinutes: 45
            ),
            TodoItem(
                title: "친구에게 연락하기",
                priority: .medium,
                category: .social,
                estimatedMinutes: 20
            ),
            TodoItem(
                title: "청소하기",
                priority: .medium,
                category: .household,
                estimatedMinutes: 60,
                repeatCycle: RepeatCycle(isRepeating: true, selectedDays: [0, 6])
            )
        ]
        
        todos = sampleTodos
        saveTodos()
    }
}

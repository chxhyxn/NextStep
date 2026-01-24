import Foundation

enum TodoPriority: String, Codable, CaseIterable {
    case low = "낮음"
    case medium = "보통"
    case high = "높음"
    case urgent = "긴급"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

enum TodoCategory: String, Codable, CaseIterable {
    case work = "업무"
    case personal = "개인"
    case health = "건강"
    case social = "사회"
    case learning = "학습"
    case household = "가사"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .social: return "person.2.fill"
        case .learning: return "book.fill"
        case .household: return "house.fill"
        }
    }
}

struct RepeatCycle: Codable, Equatable {
    var isRepeating: Bool
    var selectedDays: Set<Int> // 0 = 일요일, 1 = 월요일, ..., 6 = 토요일
    
    init(isRepeating: Bool = false, selectedDays: Set<Int> = []) {
        self.isRepeating = isRepeating
        self.selectedDays = selectedDays
    }
    
    var dayNames: [String] {
        let days = ["일", "월", "화", "수", "목", "금", "토"]
        return selectedDays.sorted().map { days[$0] }
    }
}

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var priority: TodoPriority
    var category: TodoCategory
    var estimatedMinutes: Int // 예상 소모시간 (분)
    var dueDate: Date?
    var repeatCycle: RepeatCycle
    var isCompleted: Bool
    var createdAt: Date
    
    // 둥둥 떠다니는 애니메이션을 위한 속성들 (저장하지 않음)
    var floatingOffset: CGSize = .zero
    var floatingRotation: Double = 0
    
    init(
        id: UUID = UUID(),
        title: String,
        priority: TodoPriority = .medium,
        category: TodoCategory = .personal,
        estimatedMinutes: Int = 30,
        dueDate: Date? = nil,
        repeatCycle: RepeatCycle = RepeatCycle(),
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.category = category
        self.estimatedMinutes = estimatedMinutes
        self.dueDate = dueDate
        self.repeatCycle = repeatCycle
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
    
    var estimatedTimeString: String {
        if estimatedMinutes < 60 {
            return "\(estimatedMinutes)분"
        } else {
            let hours = estimatedMinutes / 60
            let minutes = estimatedMinutes % 60
            if minutes == 0 {
                return "\(hours)시간"
            }
            return "\(hours)시간 \(minutes)분"
        }
    }
    
    var dueDateString: String? {
        guard let dueDate = dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd (E) HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: dueDate)
    }
}

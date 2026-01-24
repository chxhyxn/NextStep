import SwiftUI

struct FloatingTodosView: View {
    @Bindable var viewModel: TodoViewModel
    @State private var showingAddTodo = false
    @State private var animationTrigger = false
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [.purple.opacity(0.2), .blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 둥둥 떠다니는 할 일들
            GeometryReader { geometry in
                ForEach(Array(viewModel.incompleteTodos.enumerated()), id: \.element.id) { index, todo in
                    FloatingTodoCard(
                        todo: todo,
                        index: index,
                        animationTrigger: animationTrigger,
                        onToggle: { viewModel.toggleComplete(todo) },
                        onDelete: { viewModel.deleteTodo(todo) }
                    )
                }
            }
            
            // 하단 버튼들
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    // 추가 버튼
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("할 일 추가")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    
                    // 정리하기 버튼
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            viewModel.organizeTodos()
                        }
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("정리하기")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTodoView(viewModel: viewModel)
        }
        .onAppear {
            animationTrigger = true
        }
    }
}

struct FloatingTodoCard: View {
    let todo: TodoItem
    let index: Int
    let animationTrigger: Bool
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 카테고리 아이콘과 우선순위
            HStack {
                Image(systemName: todo.category.icon)
                    .foregroundColor(priorityColor)
                
                Spacer()
                
                Text(todo.priority.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // 제목
            Text(todo.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // 예상 시간
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                Text(todo.estimatedTimeString)
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            // 마감시간
            if let dueDateString = todo.dueDateString {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(dueDateString)
                        .font(.caption)
                }
                .foregroundColor(isDueSoon ? .red : .secondary)
            }
            
            // 반복 주기
            if todo.repeatCycle.isRepeating {
                HStack {
                    Image(systemName: "repeat")
                        .font(.caption)
                    Text(todo.repeatCycle.dayNames.joined(separator: ", "))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: priorityColor.opacity(0.3), radius: 10)
        .frame(width: 200)
        .scaleEffect(scale)
        .offset(offset)
        .rotationEffect(.degrees(rotation))
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
        .onAppear {
            setupInitialPosition()
            startFloatingAnimation()
        }
        .onChange(of: animationTrigger) {
            setupInitialPosition()
            startFloatingAnimation()
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
    
    private func setupInitialPosition() {
        // 화면 전체에 랜덤하게 배치
        let screenWidth = UIScreen.main.bounds.width - 220
        let screenHeight = UIScreen.main.bounds.height - 400
        
        // 인덱스 기반으로 시드를 설정하여 일관성 있게 배치
        var randomGenerator = SeededRandomNumberGenerator(seed: UInt64(index))
        
        let x = CGFloat.random(in: 20...max(20, screenWidth), using: &randomGenerator)
        let y = CGFloat.random(in: 100...max(100, screenHeight), using: &randomGenerator)
        
        offset = CGSize(width: x, height: y)
        rotation = Double.random(in: -15...15, using: &randomGenerator)
        
        // 나타나는 애니메이션
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
            scale = 1.0
        }
    }
    
    private func startFloatingAnimation() {
        // 둥둥 떠다니는 애니메이션
        let baseX = offset.width
        let baseY = offset.height
        
        withAnimation(
            .easeInOut(duration: Double.random(in: 3...5))
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.2)
        ) {
            offset = CGSize(
                width: baseX + CGFloat.random(in: -20...20),
                height: baseY + CGFloat.random(in: -30...30)
            )
        }
        
        withAnimation(
            .easeInOut(duration: Double.random(in: 4...6))
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.15)
        ) {
            rotation += Double.random(in: -5...5)
        }
    }
}

// 시드 기반 랜덤 생성기 (일관성 있는 랜덤 배치를 위해)
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

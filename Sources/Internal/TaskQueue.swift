import Foundation

final actor TaskQueue: Sendable {
    private let priority: TaskPriority?
    private var lastTask: Task<Void, Never>?
    
    init(priority: TaskPriority? = nil) {
        self.priority = priority
    }
    
    func spawnTask(_ action: @Sendable @escaping () async -> Void) {
        let previousTask = self.lastTask
        self.lastTask = Task { [previousTask] in
            if let previousTask {
                await previousTask.value
            }
            
            await action()
        }
    }
    
    func waitForCurrentTaskToComplete() async {
        await self.lastTask?.value
    }
}

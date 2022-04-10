import UIKit

// Синглтон
struct ConnectionManager {
    static let shared = ConnectionManager()
    private var stationsQueue: [DispatchQueue] = []
    
    private init() {}
    
    mutating func addStationQueue(_ observer: Observer) {
        // Очереди параллельные
        let queue = DispatchQueue(label: observer.name, qos: .userInteractive, attributes: .concurrent)
        stationsQueue.append(queue)
    }
    
    func addTask(with stationName: String, qos: DispatchQoS, _ task: @escaping () -> ()) {
        var isTaskRun: Bool = false
        let taskItem = DispatchWorkItem(qos: qos, flags: .inheritQoS) {
            isTaskRun.toggle()
            task()
        }
        
        let stationQueue = stationsQueue.first {
            if $0.label == stationName {
                return true
            }
            return false
        }
        
        stationQueue?.sync(execute: taskItem)
        stationQueue?.async {
            print(isTaskRun)
            print(stationName)
            if !isTaskRun {
                taskItem.cancel()
            }
        }
    }
    
    func getStationQueue(on number: Int) -> DispatchQueue {
        return stationsQueue[number]
    }
    
    mutating func updateQueues() {
        stationsQueue.removeAll()
    }
    
}

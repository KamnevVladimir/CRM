//
//  CoordinatesPresenter.swift
//  CRM
//
//  Created by Tsar on 15.05.2021.
//

import Foundation
import SwiftDate

final class CoordinatesPresenter: CoordinatesViewPresenter {
    
    private lazy var timer          = Timer.scheduledTimer(withTimeInterval: 1000, repeats: true) { _ in self.loadAirCraft() }
    private var model               = AirCrafts.shared
    private var networkService      = NetworkManager.shared
    private var connectionService   = ConnectionManager.shared
    private let output: CoordinatesPresenterOutput
    var countQueue = 0
    var noCompleteTask = [Task]()
    init(output: CoordinatesPresenterOutput) {
        self.output = output
    }
    
    func startLoad() {
        timer.fire()
    }
    
    func invalidateLoad() {
        timer.invalidate()
    }
    
    func getAirCraft(from indexPath: IndexPath) -> AirCraft {
        let row = indexPath.row
        let airCraft = model.airCrafts[row]
        return airCraft
    }
    
    func getAirCraftCount() -> Int {
        return model.airCrafts.count
    }
    
    private func modelingConflicts() {
        addStationsQueues()
        for _ in 1...15 {
            createRandomTaskItem()
        }
    }
    
    private func getObservers() -> [Observer] {
        return ObserverStations.observers
    }
    
    private func addStationsQueues() {
        connectionService.updateQueues()
        let observers = getObservers()
        for observer in observers {
            connectionService.addStationQueue(observer)
        }
    }
    
    private func createRandomTaskItem() {
        let arrayQOS: [DispatchQoS] = [.background, .default, .userInitiated, .userInteractive, .utility]
        // Создаем случайные приоритеты, выбираем случайный КА, случайную станцию
        guard let randomAirCraft = model.airCrafts.randomElement(),
              let randomStation = getObservers().randomElement(),
              let randomQOS = arrayQOS.randomElement()
        else { return }
        
        // Формируем задачи
        let task = {
            let data = randomStation.name + " " + " отправил/а данные на:" + " " + randomAirCraft.name
            self.output.updateLogs(with: data)
            randomStation.data.append(data)
        }
        
        sendingData(from: randomAirCraft, to: randomStation, task: task, qos: randomQOS)
    }
    
    private func sendingData(from airCraft: AirCraft, to station: Observer, task: @escaping () -> (), qos: DispatchQoS) {
        // Если изначальная станция в ЗРВ, то проверяем занятость
        if isStationVisible(airCraft: airCraft, station: station) {
            // Если изнач.станция занята, то проверяем след.станцию на ЗРВ
            if isStationBusy(station: station) {
                logicWithVisibleSecondStation(airCraft: airCraft, station: station, task: task, qos: qos)
            } else { // Если изнач.станция свободна, то выполняем задачу
                let taskItem = formingTaskItem(qos: qos, task: task, station: station, airCraft: airCraft)
                runTask(taskItem, station: station)
                return
            }
        } else {
            logicWithVisibleSecondStation(airCraft: airCraft, station: station, task: task, qos: qos)
        }
        
    }
    
    private func logicWithVisibleSecondStation(airCraft: AirCraft, station: Observer, task: @escaping () -> (), qos: DispatchQoS) {
        guard let nextStation = detectNextStation(at: station) else { return }
        if isStationVisible(airCraft: airCraft, station: nextStation) {
            logicWithCountTaskFirstStation(airCraft: airCraft, station: station, task: task, qos: qos)
        } else { // Если след. станция в ЗРВ, то смотрим ее занятость
            if isStationBusy(station: station) {
                logicWithCountTaskFirstStation(airCraft: airCraft, station: station, task: task, qos: qos)
            } else { // Если след.станция свободна, то задача выполняется
                let taskItem = formingTaskItem(qos: qos, task: task, station: nextStation, airCraft: airCraft)
                runTask(taskItem, station: nextStation)
                return
            }
        }
    }
    
    private func logicWithCountTaskFirstStation(airCraft: AirCraft, station: Observer, task: @escaping () -> (), qos: DispatchQoS) {
        // Если количество - 1 задач на след.станции > количества ЗРВ КА, то смотрим количество задач на след. станции
        if isCountTaskHuge(airCraft: airCraft, station: station) {
            guard let nextStation = detectNextStation(at: station) else { return }
            print("зашло")
            if isCountTaskHuge(airCraft: airCraft, station: nextStation) {
                let log = "Станция \(station.name) откладывает данные на \(airCraft.name)"
                output.updateLogs(with: log)
                return
            } else { // Если количество задач на след.стацнии удовлетворяет, то добавляем задачу в пул задач станции
                let taskItem = formingTaskItem(qos: qos, task: task, station: nextStation, airCraft: airCraft)
                runTask(taskItem, station: nextStation)
                return
            }
        } else { // Если количество задач на изнач. станции удовлетворяет, то добавляем задачу в пул задач станции
            let taskItem = formingTaskItem(qos: qos, task: task, station: station, airCraft: airCraft)
            runTask(taskItem, station: station)
            
            let log = "Станция \(station.name) отправляет данные на \(airCraft.name)"
            output.updateLogs(with: log)
            return
        }
    }
    
    private func isCountTaskHuge(airCraft: AirCraft, station: Observer) -> Bool {
        let passes = getPasses(for: airCraft, with: station)
        if station.currentTasksCount == 0 {
            return false
        }
        if station.currentTasksCount - 1 > passes {
            return true
        }
        return false
    }
    
    private func isStationBusy(station: Observer) -> Bool {
        if station.isBusy {
            return true
        }
        return false
    }
    
    private func isStationVisible(airCraft: AirCraft, station: Observer) -> Bool {
        let passes = getPasses(for: airCraft, with: station)
        if passes == 0 {
            return false
        }
        return true
        
    }
    
    private func formingTaskItem(qos: DispatchQoS, task: @escaping () -> (), station: Observer, airCraft: AirCraft) -> DispatchWorkItem {
        let taskItem = DispatchWorkItem(qos: qos, flags: .inheritQoS) { [weak self] in
            guard let self = self else { return }
            let startlog = "Станция \(station.name) отправляет данные на \(airCraft.name)"
            self.output.updateLogs(with: startlog)
            
            station.isBusy = true
            station.currentTasksCount += 1
            
            task()
            
            station.currentTasksCount -= 1
            station.isBusy = false
            
            let endLog = "Станция \(station.name) отправила данные на \(airCraft.name)"
            self.output.updateLogs(with: endLog)
        }
        return taskItem
    }
    
    private func runTask(_ task: DispatchWorkItem, station: Observer) {
        guard let stationNumber = getStationNumber(station) else { return }
        let queue = getStationQueue(from: stationNumber)
        queue.async(execute: task)
    }
    
    private func detectNextStation(at station: Observer) -> Observer? {
        guard let numberCurrentStation = getStationNumber(station) else { return nil }
        // Если число вышло за пределы количества станций, то след. станция с индексом 0
        let nextNumberStation = numberCurrentStation % ObserverStations.observers.count
        let nextStation = ObserverStations.observers[nextNumberStation]
    
        return nextStation
    }
    
    private func getStationNumber(_ station: Observer) -> Int? {
        // Нашли индекс
        let indexCurrentStation = ObserverStations.observers.firstIndex {
            if $0.latitude == station.latitude && $0.longitude == station.longitude {
                return true
            }
            return false
        }
        guard let index = indexCurrentStation else { return nil }
        // Перевели его в тип Integer
        let numberCurrentStation = Int(index.magnitude)
        return numberCurrentStation
    }
    
    private func getStationQueue(from number: Int) -> DispatchQueue {
        return connectionService.getStationQueue(on: number)
    }
    
    private func getPasses(for airCraft: AirCraft, with station: Observer) -> Int {
        let id = airCraft.id
        var passes = 0
        
        networkService.fetchPasses(for: id, observer: station) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let passe):
                    passes = passe.passesCount
                default:
                    passes = 0
                }
            }
        }
        
        return passes
    }
}

// MARK: - Основной алгоритм
extension CoordinatesPresenter {
    
    private func loadAirCraft() {
        let observer = ObserverStations.observers[0]
        let idArray = model.ids
        
        idArray.forEach {
            networkService.fetchAirCraft(id: $0, observer: observer) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let airCraft):
                        self.model.append(airCraft)
                        self.output.updateUI()
//                        self.modelingConflicts()
                        if self.model.airCrafts.count == self.model.ids.count {
                            self.loadAirCraftPasses()
                        }
                    default:
                        return
                    }
                }
            }
        }
    }
    
    private func loadAirCraftPasses() {
        let aircrafts   = model.airCrafts
        let observers   = ObserverStations.observers
        var count       = 0
        let finalCount  = aircrafts.count * observers.count - 1
        for aircraft in aircrafts {
            for observer in observers {
                networkService.fetchAirPasses(for: aircraft.id, observer: observer) { [weak self] result in
                    guard let self = self else { return }
                    count += 1
                    switch result {
                    case .success(let passes) :
                        aircraft.airPasses.append(contentsOf: passes)
                        self.createCSV(for: observer.name, aircraftName: aircraft.name, with: passes)
                    case .failure(_):
                        break
                    }
                    if count == finalCount {
                        self.modelingGCD(with: aircrafts)
                    }
                }
            }
        }
    }
    
    private func modelingGCD(with aircrafts: [AirCraft]) {
        let aircrafts = aircrafts
        let stack     = SharedTasks.shared
        let arrayQOS: [DispatchQoS] = [.background, .default, .userInitiated, .userInteractive, .utility]
        
        for i in 0...800 {
            guard let randomAirCraft = model.airCrafts.randomElement(),
                  let randomStation  = getObservers().randomElement(),
                  let randomQOS      = arrayQOS.randomElement()
            else { return }
            let randomTime      = UInt32.random(in: 1...10)
            let hasStation      = Bool.random()
            let name            = "Задача №\(i)"
            let main            = {
                sleep(randomTime * 60 + 300)
                print(name + ": передача информации с \(randomStation.name) на \(randomAirCraft.name) завершена")
            }
            let task            = Task(
                name            : name,
                main            : main,
                duration        : Int(randomTime * 60 + 300),
                qos             : randomQOS,
                station         : hasStation ? randomStation : nil,
                aircraft        : randomAirCraft
            )
            stack.tasks.append(task)
            randomAirCraft.queue.append(task)
        }
        
        createTaskCSV(with: stack.tasks)
        let queue    = DispatchQueue(label: "queue", qos: .userInteractive)
        queue.sync { [weak self] in
            guard let self = self else { return }
            for aircraft in aircrafts {
                self.countQueue = aircrafts.count
                self.createQueues(for: aircraft, with: arrayQOS.randomElement() ?? .default, onEnd: {
                    self.countQueue -= 1
                    if self.countQueue == 0 {
                        self.createCSV()
                        self.createNoCompleteCSV()
                    }
                })
            }
        }
    }
    
    private func createQueues(for aircraft: AirCraft, with qos: DispatchQoS, onEnd: @escaping (()->())) {
        var queue = aircraft.queue
        while !queue.isEmpty {
            var findPass: AirPass?
            if let index   = queue[0].aircraft.airPasses.firstIndex(where: {
                if let station = queue[0].station {
                    return $0.duration > queue[0].duration && $0.station.type == station.type
                } else {
                    return $0.duration > queue[0].duration
                }
            }) {
                findPass = queue[0].aircraft.airPasses[index]
            }

            if let pass = findPass {
                let startPass       = pass.start
                let startInterval   = Int(startPass.timeIntervalSince1970) / 60
                let taskDuration    = queue[0].duration
                let station         = pass.station

                var isBusy          = false
                for min in 0...taskDuration {
                    let interval = startInterval + min
                    if station.busyTimes[interval] != nil {
                       isBusy = true
                    }
                }

                if !isBusy {
                    for min in 0...taskDuration / 60 {
                        let interval = startInterval + min
                        station.busyTimes[interval] = queue[0]
                    }
                    queue[0].date = pass.start
                    queue.remove(at: 0)
                    pass.start = pass.start + taskDuration.seconds
                    pass.duration -= taskDuration
                } else {
                    noCompleteTask.append(queue[0])
                    queue.remove(at: 0)
                    pass.start = pass.start + taskDuration.seconds
                    pass.duration -= taskDuration
                }
            } else {
                noCompleteTask.append(queue[0])
                queue.remove(at: 0)
                break
            }
            onEnd()
        }
    }
    
    private func createNoCompleteCSV() {
        var csvString = "Имя задачи,Станция,ЛА,Приоритет,Продолжительность [мин.]\n"
        for task in noCompleteTask {
            csvString += "\(task.name),\(task.station?.type.rawValue ?? "Не указана"),\(task.aircraft.name),\(task.qos.qosClass.rawValue.rawValue),\(task.duration / 60)\n"
        }
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("Нераспределенные задачи.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .unicode)
        } catch {
            print("error creating file")
        }
    }
    
    private func createTaskCSV(with tasks: [Task]) {
        var csvString = "Имя задачи,Станция,ЛА,Приоритет,Продолжительность [мин.]\n"
        for task in tasks {
            csvString += "\(task.name),\(task.station?.type.rawValue ?? "Не указана"),\(task.aircraft.name),\(task.qos.qosClass.rawValue.rawValue),\(task.duration / 60)\n"
        }
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("Задачи.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .unicode)
        } catch {
            print("error creating file")
        }
    }
    
    private func createCSV() {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        for station in ObserverStations.observers {
            var csvString = "Станция \(station.name.replacingOccurrences(of: ",", with: " "))\n"
            csvString += "Имя задачи,Дата,Интервал,Продолжительность [мин.]\n"
            for stroke in station.busyTimes {
                if let taskDate = stroke.value.date {
                    let interval = Double(taskDate.timeIntervalSince1970 / 60).rounded()
                    if !csvString.contains("\(stroke.value.name)") {
                        csvString += "КА \(stroke.value.aircraft.name.replacingOccurrences(of: ",", with: " ")),\(stroke.value.name),\(dateFormatter.string(from: taskDate)),\(interval),\(stroke.value.duration / 60)\n"
                    }
                }
            }
            
            let fileManager = FileManager.default
            do {
                let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
                let fileURL = path.appendingPathComponent("\(station.type.rawValue).csv")
                try csvString.write(to: fileURL, atomically: true, encoding: .unicode)
            } catch {
                print("error creating file")
            }
        }
    }
    
    private func createCSV(for observer: String, aircraftName: String, with passes: [AirPass]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        var csvString = "Имя КА \(aircraftName), станция \(observer)\n"
        csvString += "Начало связи, Окончание связи, Продолжительность сеанса [c]\n"
        for pass in passes {
            csvString += "\(dateFormatter.string(from: pass.start)),\(dateFormatter.string(from: pass.end)),\(pass.duration)\n"
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("\(aircraftName)-\(observer).csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .unicode)
        } catch {
            print("error creating file")
        }
    }
}

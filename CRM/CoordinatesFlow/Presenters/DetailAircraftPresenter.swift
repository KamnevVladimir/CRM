//
//  CoordinatesPresenter.swift
//  CRM
//
//  Created by Tsar on 15.05.2021.
//

import Foundation

class DetailAircraftPresenter: DetailViewPresenter {
    
    private lazy var timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in self.loadAirCraft() }
    private lazy var model = AirCrafts.shared
    private lazy var networkService = NetworkManager.shared
    private let output: DetailPresenterOutput
    private var airCraft: AirCraft
    private var passes: [AirCraftPasses] = []
    
    init(output: DetailPresenterOutput, airCraft: AirCraft) {
        self.output = output
        self.airCraft = airCraft
    }
    
    func startLoad() {
        timer.fire()
    }
    
    private func loadAirCraft() {
        let observer = ObserverStations.observers[0]
        let id = airCraft.id
        
        networkService.fetchAirCraft(id: id, observer: observer) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let airCraft):
                    self.airCraft = airCraft
                    self.loadAirCraftPasses()
                default:
                    return
                }
            }
        }
        
    }
    
    private func loadAirCraftPasses() {
        passes.removeAll()
        let observers = ObserverStations.observers
        let id = airCraft.id
        
        observers.forEach {
            networkService.fetchPasses(for: id, observer: $0) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let passe):
                        self.passes.append(passe)
                        self.output.updateUI()
                    default:
                        return
                    }
                }
            }
        }
    }
    
    
    func invalidateLoad() {
        timer.invalidate()
    }
    
    func getAirCraft() -> AirCraft {
        return airCraft
    }
    
    func getPasses() -> [AirCraftPasses] {
        return passes
    }
    
    func getObservers() -> [Observer] {
        let observers = ObserverStations.observers
        return observers
    }
    
    func stationSend(with id: Int) {
        let observer = ObserverStations.observers[id]
        observer.isBusy = true
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
            observer.isBusy = false
        }
    }
}



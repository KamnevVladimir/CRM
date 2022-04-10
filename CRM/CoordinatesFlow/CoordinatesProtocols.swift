//
//  CoordinatesProtocols.swift
//  CRM
//
//  Created by Tsar on 15.05.2021.
//

import Foundation

//MARK: - Coordinates Controller
protocol CoordinatesViewPresenter {
    func startLoad()
    func invalidateLoad()
    func getAirCraft(from indexPath: IndexPath) -> AirCraft
    func getAirCraftCount() -> Int
}

protocol CoordinatesPresenterOutput {
    func updateUI()
    func updateLogs(with text: String) 
}

//MARK: - Detail Controller
protocol DetailViewPresenter {
    func getAirCraft() -> AirCraft
    func getPasses() -> [AirCraftPasses]
    func getObservers() -> [Observer]
    func startLoad()
    func invalidateLoad()
    func stationSend(with id: Int)
}

protocol DetailPresenterOutput {
    func updateUI()
}


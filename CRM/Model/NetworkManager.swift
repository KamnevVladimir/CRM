//
//  AirCraftManager.swift
//  CRM
//
//  Created by Tsar on 15.05.2021.
//

import Foundation
import SwiftyJSON

enum AirCraftDataType {
    case airCraft
    case passes
    case radio
}

enum NerworkErrors: Error {
    case notResponse
}

// Singletone
struct NetworkManager: NetworkManagerProtocol {
    
    static  let shared = NetworkManager()
    private let apiKey = "925VGG-SV67LC-AGMD62-4PW1"
    
    private init() {}
     
    private func getUrl(from type: AirCraftDataType, airCraftId id: Int, observer: Observer) -> URL? {
        // Параметры станции
        let obsLatitude     = observer.latitude
        let obsLongitude    = observer.longitude
        let obsAltitude     = observer.altitude
        // URL в зависимости от типа ЛА
        switch type {
        case .airCraft:
            let urlString = "https://api.n2yo.com/rest/v1/satellite/positions/\(id)/\(obsLatitude)/\(obsLongitude)/\(obsAltitude)/1/&apiKey=" + apiKey
            return URL(string: urlString)
        case .passes:
            let urlString = "https://api.n2yo.com/rest/v1/satellite/visualpasses/\(id)/\(obsLatitude)/\(obsLongitude)/\(obsAltitude)/4/60/&apiKey=" + apiKey
            /// Моделируется 4 дня по 1 минуте
            return URL(string: urlString)
        case .radio:
            let urlString = "https://api.n2yo.com/rest/v1/satellite/radiopasses/\(id)/\(obsLatitude)/\(obsLongitude)/\(obsAltitude)/4/7/&apiKey=" + apiKey
            return URL(string: urlString)
        }
    }
    
    // Метод получения видимости ЛА из сети
    func fetchPasses(for id: Int, observer: Observer, completion: @escaping (Result<AirCraftPasses, Error>) -> Void) {
        guard let url = getUrl(from: AirCraftDataType.passes, airCraftId: id, observer: observer) else { return }
        print(url)
        // Формируем и посылаем задачу в сессию связи
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            
            do {
                let json = try JSON(data: data)
                guard
                    let passes = AirCraftPasses.get(from: json)
                else {
                    completion(.failure(NerworkErrors.notResponse))
                    return }
                completion(.success(passes))
            } catch {
                completion(.failure(NerworkErrors.notResponse))
            }
        }.resume()
    }
    
    // Метод получения видимости ЛА из сети
    func fetchAirPasses(for id: Int, observer: Observer, completion: @escaping (Result<[AirPass], Error>) -> Void) {
        guard let url = getUrl(from: AirCraftDataType.radio, airCraftId: id, observer: observer) else { return }
        print(url)
        // Формируем и посылаем задачу в сессию связи
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            
            do {
                let json = try JSON(data: data)
                let passes = AirPass.get(from: json, station: observer)
                completion(.success(passes))
            } catch {
                completion(.failure(NerworkErrors.notResponse))
            }
        }.resume()
    }
    
    // Метод получения данных ЛА из сети
    func fetchAirCraft(id: Int, observer: Observer, completion: @escaping (Result<AirCraft, Error>) -> Void) {
        guard
            let url = getUrl(from: AirCraftDataType.airCraft, airCraftId: id, observer: observer)
        else { return }
        // Формируем и посылаем задачу в сессию связи
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let json = try JSON(data: data)
                guard let airCraft = AirCraft.get(from: json, id: id) else {
                    completion(.failure(NerworkErrors.notResponse))
                    return }
                completion(.success(airCraft))
            } catch {
                completion(.failure(NerworkErrors.notResponse))
            }
        }.resume()
    }
}

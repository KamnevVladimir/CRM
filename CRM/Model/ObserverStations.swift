//
//  ObserverStation.swift
//  CRM
//
//  Created by Tsar on 15.05.2021.
//

import Foundation

enum ObserverLocation: String {
    case Moscow
    case Zheleznogorsk
    case Kaliningrad
    case Sakhalin
}

final class Observer {
    let type                : ObserverLocation
    let name                : String
    let latitude            : Float
    let longitude           : Float
    let altitude            : Float
    var data                : [String] = []
    var isBusy              : Bool
    var currentTasksCount   : Int = 0
    var summaryBusyTime     : Float = 0
    var deferredTask        : (() -> ())? = nil
    var busyTimes           : [Int: Task] = .init()
    
    init(type: ObserverLocation, name: String, latitude: Float, longitude: Float, altitude: Float, isBusy: Bool = false) {
        self.name       = name
        self.latitude   = latitude
        self.longitude  = longitude
        self.altitude   = altitude
        self.isBusy     = isBusy
        self.type       = type
    }
}

struct ObserverStations {
    
    static let observers: [Observer] = [
        Observer(
            type        : .Moscow,
            name        : "КИС Клён-М, ЗКИП (РКС), г. Москва",
            latitude    : 55.75,
            longitude   : 37.7333,
            altitude    : 300
        ),
        Observer(
            type        : .Zheleznogorsk,
            name        : "КИС Клён, ЦКИП, г. Железногорск",
            latitude    : 56.2866,
            longitude   : 93.55083,
            altitude    : 166
        ),
        Observer(
            type        : .Kaliningrad,
            name        : "Балтийский КИП, Калининградская обл.",
            latitude    : 54.7083,
            longitude   : 20.5631,
            altitude    : 80
        ),
        Observer(
            type        : .Sakhalin,
            name        : "ВКИП (ИП Сахалин), Сахалинская обл.",
            latitude    : 46.9167,
            longitude   : 142.7167,
            altitude    : 15
        )
    ]
}

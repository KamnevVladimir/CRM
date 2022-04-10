//
//  Sputnik.swift
//  CRM
//
//  Created by Tsar on 15.05.2021.
//

import Foundation
import SwiftyJSON

class AirCraft {
    
    let id          : Int
    let name        : String
    let latitude    : Float
    let longitude   : Float
    var airPasses   : [AirPass] {
        didSet {
            airPasses.sort(by: { $0.start < $1.start })
        }
    }
    var queue       : [Task] = [] {
        didSet {
            if needSortQueue {
                queue.sort(by: { $0.qos.relativePriority < $1.qos.relativePriority })
            }
        }
    }
    var needSortQueue = true

    
    init(id: Int, name: String, latitude: Float, longitude: Float, airPasses: [AirPass]) {
        self.id             = id
        self.name           = name
        self.latitude       = latitude
        self.longitude      = longitude
        self.airPasses      = airPasses
    }
    
    static func get(from json: JSON, id: Int) -> AirCraft? {
        guard
            let latitude  = json["positions"].arrayValue.first?["satlatitude"].float,
            let longitude = json["positions"].arrayValue.first?["satlongitude"].float,
            let name      = json["info"]["satname"].string
        else { return nil }
        
        return AirCraft(
            id          : id,
            name        : name,
            latitude    : latitude,
            longitude   : longitude,
            airPasses   : []
        )
    }
}

final class AirPass {
    let id          = arc4random()
    var start       : Date
    let end         : Date
    var duration    : Int
    let station     : Observer
    
    init(start: Date, end: Date, duration: Int, station: Observer) {
        self.start      = start
        self.end        = end
        self.duration   = duration
        self.station    = station
    }
    
    static func get(from json: JSON, station: Observer) -> [AirPass] {
        var passes      = [AirPass]()
        for json in json["passes"].arrayValue {
            let startValue      = json["startUTC"].doubleValue
            let endValue        = json["endUTC"].doubleValue
            let duration        = Int(abs(endValue - startValue))
            let startDate       = Date(timeIntervalSince1970: startValue)
            let endDate         = Date(timeIntervalSince1970: endValue)
            passes.append(.init(
                start       : startDate,
                end         : endDate,
                duration    : duration,
                station     : station
            ))
        }
  
        return passes
    }
}

struct AirCraftPasses {
    
    let passesCount: Int
    
    static func get(from json: JSON) -> AirCraftPasses? {
        guard
            let passescount = json["info"]["passescount"].int
        else { return nil }
        
        return AirCraftPasses(passesCount: passescount)
    }
}

struct AirCrafts {
    
    static let shared = AirCrafts()
    
    private init() { }
    
    let ids: [Int] = [47229, 46287, 44909, 44414, 43876, 43032, 41465, 40921, 40553]
    
    var airCrafts   : [AirCraft] = []
    
    mutating func append(_ airCraft: AirCraft) {
        airCrafts.append(airCraft)
    }
    
    mutating func deleteAll() {
        airCrafts.removeAll()
    }
}

final class Task {
    
    let name        : String
    var main        : (()->())
    let duration    : Int
    let qos         : DispatchQoS
    let station     : Observer?
    let aircraft    : AirCraft
    var date        : Date? = nil
    
    init(name: String, main: @escaping (()->()), duration: Int, qos: DispatchQoS, station: Observer?, aircraft: AirCraft) {
        self.name       = name
        self.main       = main
        self.duration   = duration
        self.qos        = qos
        self.station    = station
        self.aircraft   = aircraft
    }
    
    func start() {
        main()
    }
}

final class SharedTasks {
    
    static let shared = SharedTasks()
    
    private init() { }
    
    var tasks = [Task]()
}

public extension Collection {
    
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


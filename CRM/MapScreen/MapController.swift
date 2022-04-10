//
//  MapController.swift
//  CRM
//
//  Created by vskamnev on 10.04.2022.
//

import UIKit
import MapKit

final class MapController:
    UIViewController,
    MKMapViewDelegate
{
    
    private let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        addSubviews()
        
        setupMap()
        drawStations()
    }
    
    private func initialSetup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.1)
        
        title = "Отображение на карте"
        
        let image = UIImage(named: "map")
        tabBarItem = UITabBarItem(title: "Карта", image: image, selectedImage: image)
    }
    
    private func addSubviews() {
        view.addSubviews(
            mapView
        )
    }
    
    // MARK: - Map Methods
    private func setupMap() {
        mapView.frame = view.frame
        mapView.delegate = self
        
        mapView.register(
          StationMarkerView.self,
          forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        
        let initialLocation = CLLocation(latitude: 55.7522200, longitude: 37.61556)
        mapView.centerToLocation(initialLocation)
    }
    
    private func drawStations() {
        guard let stationImage = UIImage(named: "station") else { return }
        let observers = ObserverStations.observers
        for observer in observers {
            let stationAnnotation = StationAnnotation(
                title: "Станция",
                subtitle: observer.name,
                discipline: "station",
                coordinate: observer.coordinate,
                image: stationImage
            )
            mapView.addAnnotation(stationAnnotation)
        }
        
        drawAircrafts(with: UIImage(named: "la") ?? .init())
    }
    
    private func drawAircrafts(with image: UIImage) {
        let idArray = AirCrafts.shared.ids
        
        idArray.forEach {
            NetworkManager.shared.fetchAirCraft(id: $0, observer: ObserverStations.observers[0]) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let airCraft):
                        let stationAnnotation = StationAnnotation(
                            title: "Летательный аппарат",
                            subtitle: airCraft.name,
                            discipline: "aircraft",
                            coordinate: CLLocationCoordinate2D(latitude: .init(airCraft.latitude), longitude: .init(airCraft.longitude)),
                            image: image
                        )
                        self.mapView.addAnnotation(stationAnnotation)
                    default:
                        return
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is StationAnnotation:
            return StationMarkerView(annotation: annotation, reuseIdentifier: "station")
        default:
            return nil
        }
    }
}

// MARK: - Extensions
private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 2_500_000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius
    )
    setRegion(coordinateRegion, animated: true)
  }
}

final class StationAnnotation: NSObject, MKAnnotation {
    let title: String? // Имя
    let subtitle: String?
    let discipline: String? // станция / спутник
    let coordinate: CLLocationCoordinate2D
    let image: UIImage
    
    init(
        title: String?,
        subtitle: String?,
        discipline: String?,
        coordinate: CLLocationCoordinate2D,
        image: UIImage
    ) {
        self.title = title
        self.subtitle = subtitle
        self.discipline = discipline
        self.coordinate = coordinate
        self.image = image
        
        super.init()
    }
}

final class StationMarkerView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let station = newValue as? StationAnnotation else { return }
            image = station.image
            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
    }
}

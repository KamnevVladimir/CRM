//
//  TaskAlertController.swift
//  CRM
//
//  Created by Tsar on 17.05.2021.
//

//import UIKit
//
//class TaskAlertController: UIAlertController {
//    private let isTaskRun: Bool
//    private let station: String
//    
//    init(isTaskRun: Bool, station: String) {
//        self.isTaskRun = isTaskRun
//        self.station = station
//        super.init(nibName: nil, bundle: nil)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//    }
//
//    private func setupView() {
//        title = "Название станции: " + station
//        if isTaskRun {
//            message = "Задача запущена"
//        } else {
//            message = "Станция занята, задача не запущена"
//        }
//        
//        let action = UIAlertAction(title: "Поставить в ожидании", style: .default) { _ in
//            print("Чебурек")
//        }
//    }
//}

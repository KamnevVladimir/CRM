//
//  CoordinatesViewController.swift
//  CRM
//
//  Created by Tsar on 13.05.2021.
//

import UIKit
import PinLayout

final class CoordinatesViewController: UIViewController {
    
    private lazy var presenter: CoordinatesViewPresenter = CoordinatesPresenter(output: self)
    
    private lazy var tableView: UITableView = {
        let tableView               = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor   = UIColor.clear
        tableView.dataSource        = self
        tableView.delegate          = self
        tableView.register(
            CoordinatesTableVHFV.self,
            forHeaderFooterViewReuseIdentifier: String(describing: CoordinatesTableVHFV.self)
        )
        tableView.register(
            CoordinatesTableVC.self,
            forCellReuseIdentifier: String(describing: CoordinatesTableVC.self)
        )
        return tableView
    }()
    
    private lazy var logsTextView: UITextView = {
        let textView                = UITextView()
        textView.backgroundColor    = UIColor.systemGreen.withAlphaComponent(0.2)
        textView.textColor          = UIColor.black.withAlphaComponent(0.8)
        textView.text               = "Данные моделирования конфликтных ситуаций"
        return textView
    }()
    
    private lazy var backView   = UIView()
    private lazy var timer      = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureView()
        configureNavigationItem()
        configureTabBarItem()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLayouts()
        configureTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        presenter.startLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.invalidateLoad()
    }
    
    private func setupViews() {
        view.addSubview(backView)
        backView.addSubviews(tableView,
                             logsTextView)
    }
    
    private func setupLayouts() {
        backView.pin
            .all()
        logsTextView.pin
            .height(UIScreen.main.bounds.height / 3)
            .horizontally(20)
            .bottom(view.pin.safeArea.bottom)
            .marginBottom(10)
        tableView.pin
            .horizontally()
            .top(view.pin.safeArea.top)
            .bottom(to: logsTextView.edge.top)
            .marginBottom(10)
    }
    
    private func configureTextView() {
        if logsTextView.layer.cornerRadius == 0 {
            logsTextView.layer.cornerRadius = 10
        }
    }

    private func configureView() {
        view.backgroundColor = .white
        backView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
    }
    
    private func configureNavigationItem() {
        navigationController?.navigationBar.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.1)
        title = "Местоположение ЛА"
    }
    
    private func configureTabBarItem() {
        let image = UIImage(named: "aircraft")
        tabBarItem = UITabBarItem(title: "Положение", image: image, selectedImage: image)
        tabBarController?.tabBar.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.1)
    }
    
    private func loadAirCraft() {
        
    }
}

extension CoordinatesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getAirCraftCount()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CoordinatesTableVC.self)) as? CoordinatesTableVC else { return UITableViewCell() }
        let airCraft = presenter.getAirCraft(from: indexPath)
        cell.configure(with: airCraft)
        return cell
        
    }
}

extension CoordinatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let aircraft = presenter.getAirCraft(from: indexPath)
        let viewController = DetailAircraftViewController(airCraft: aircraft)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: CoordinatesTableVHFV.self))
        return headerView
    }
}

// Выход Таблицы
extension CoordinatesViewController: CoordinatesPresenterOutput {
    func updateUI() {
        tableView.reloadData()
    }
    
    func updateLogs(with text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard var logText = self.logsTextView.text  else { return }
            logText += "\n" + text
            self.logsTextView.text = logText
        }
    }
}

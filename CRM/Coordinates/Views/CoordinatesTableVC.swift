//
//  CoordinatesTableViewCell.swift
//  CRM
//
//  Created by Tsar on 15.05.2021.
//

import UIKit

final class CoordinatesTableVC: UITableViewCell {
    // Настройка компонентов
    private lazy var idView = UIView()
    private lazy var nameView = UIView()
    private lazy var longView = UIView()
    private lazy var latView = UIView()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.text = "ID"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Наименование"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var longLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Долгота"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var latLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Широта"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    // Константы ячейки, вложенный тип
    struct LayoutConstraints {
        static let offset: CGFloat = 6
        static let widthScreen = UIScreen.main.bounds.width - offset * 5
        static let heightCell: CGFloat = 50
    }
    
    // Инициализация
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Метод жизненного цикла UIView
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        setupLayouts()
        configureViews()
        return CGSize(width: contentView.frame.width, height: LayoutConstraints.heightCell)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [idLabel, nameLabel, longLabel, latLabel].forEach {
            $0.text = nil
        }
    }
    
    // Добавляем элементы в ячейку и делаем первоначальную настройку
    private func setupViews() {
        backgroundColor = .clear
        contentView.addSubviews(idView,
                                nameView,
                                longView,
                                latView)
        idView.addSubview(idLabel)
        nameView.addSubview(nameLabel)
        longView.addSubview(longLabel)
        latView.addSubview(latLabel)
        
        [idView, nameView, longView, latView].forEach {
            $0.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        }
    }
    
    // Задаем им положение на экране
    private func setupLayouts() {
        idView.pin
            .start(LayoutConstraints.offset)
            .width(LayoutConstraints.widthScreen * 0.15)
            .height(LayoutConstraints.heightCell - 6)
            .vertically(3)
        nameView.pin
            .start(to: idView.edge.end)
            .width(LayoutConstraints.widthScreen * 0.35)
            .height(LayoutConstraints.heightCell - 6)
            .vertically(3)
            .marginStart(LayoutConstraints.offset)
        longView.pin
            .start(to: nameView.edge.end)
            .width(LayoutConstraints.widthScreen * 0.25)
            .height(LayoutConstraints.heightCell - 6)
            .vertically(3)
            .marginStart(LayoutConstraints.offset)
        latView.pin
            .start(to: longView.edge.end)
            .width(LayoutConstraints.widthScreen * 0.25)
            .height(LayoutConstraints.heightCell - 6)
            .vertically(3)
            .marginStart(LayoutConstraints.offset)
        
        [idLabel, nameLabel, longLabel, latLabel].forEach{
            $0.pin.all()
        }
        
    }
    
    // Добавляем закругление и тени на ячейки
    private func configureViews() {
        if idView.layer.cornerRadius == 0 {
            [idView, nameView, longView, latView].forEach {
                $0.layer.cornerRadius = 10
            }
        }
    }
    
    func configure(with airCraft: AirCraft) {
        idLabel.text    = String(airCraft.id)
        nameLabel.text  = airCraft.name
        longLabel.text  = String(airCraft.longitude) + " º"
        latLabel.text   = String(airCraft.latitude) + " º"
    }
    
}

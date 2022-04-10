//
//  CoordinatesTableViewCell.swift
//  CRM
//
//  Created by Tsar on 15.05.2021.
//

import UIKit

final class CoordinatesTableVHFV: UITableViewHeaderFooterView {
    // Настройка компонентов
    private lazy var backView: UIView? = UIView()
    private lazy var secondBackView = UIView()
    
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
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
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
        backView = nil
    }
    
    // Добавляем элементы в ячейку и делаем первоначальную настройку
    private func setupViews() {
        guard
            let backView = backView
        else { return }
        
        contentView.addSubviews(backView)
        backView.addSubview(secondBackView)
        secondBackView.addSubviews(
            idLabel,
            nameLabel,
            longLabel,
            latLabel
        )
        
        backView.backgroundColor        = .white
        secondBackView.backgroundColor  = UIColor.systemTeal.withAlphaComponent(0.1)
    }
    
    // Задаем им положение на экране
    private func setupLayouts() {
        guard let backView = backView else { return }
        backView.pin
            .all()
            .height(LayoutConstraints.heightCell)
        secondBackView.pin
            .all()
        idLabel.pin
            .start(LayoutConstraints.offset)
            .width(LayoutConstraints.widthScreen * 0.15)
            .height(LayoutConstraints.heightCell)
            .vertically()
        nameLabel.pin
            .start(to: idLabel.edge.end)
            .width(LayoutConstraints.widthScreen * 0.35)
            .height(LayoutConstraints.heightCell)
            .vertically()
            .marginStart(LayoutConstraints.offset)
        longLabel.pin
            .start(to: nameLabel.edge.end)
            .width(LayoutConstraints.widthScreen * 0.25)
            .height(LayoutConstraints.heightCell)
            .vertically()
            .marginStart(LayoutConstraints.offset)
        latLabel.pin
            .start(to: longLabel.edge.end)
            .width(LayoutConstraints.widthScreen * 0.25)
            .height(LayoutConstraints.heightCell)
            .vertically()
            .marginStart(LayoutConstraints.offset)
    }
    
    // Добавляем закругление и тени на ячейки
    private func configureViews() {
        guard let backView = backView else { return }
        
        backView.addShadow(type: .outside, power: 1, alpha: 0.15, offset: 1)
    }
    
}

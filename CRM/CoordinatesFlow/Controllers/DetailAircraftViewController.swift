import UIKit
import PinLayout

// Контроллер детальной информации
final class DetailAircraftViewController: UIViewController {
    // Свойства контроллера
    private var presenter: DetailViewPresenter? = nil
    private var airCraft: AirCraft
    private var isFirstStationVisible = false
    private var isSecondStationVisible = false
    private var isThirdStationVisible = false
    private var isFortyStationVisible = false
    
    private lazy var backView = UIView()
    private lazy var longTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var latTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var passesLabel: UILabel = {
        let label = UILabel()
        label.text = "В зоне видимости"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var underPassesLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        return view
    }()
    
    private lazy var firstStationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
    private lazy var secondStationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
    private lazy var thirdStationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
    private lazy var fortyStationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "earth")?.withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    struct LayoutConstants {
        static let textFieldInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        static let horizontalOffset: CGFloat = 20
        static let imageSize = CGSize(width: 100, height: 100)
        static let verticalOffset: CGFloat = 10
        static let textEndOffset = imageSize.width + 2 * horizontalOffset
    }
    
    // Инициализация
    init(airCraft: AirCraft) {
        self.airCraft = airCraft
        super.init(nibName: nil, bundle: nil)
        presenter = DetailAircraftPresenter(output: self, airCraft: airCraft)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationItem()
        setupStationLabels()
        hideKeyboardWhenTappedAround()
        setupText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.startLoad()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.invalidateLoad()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLayouts()
    }
    
    private func setupText() {
        guard let presenter = presenter else { return }
        
        longTitleLabel.text = "Долгота: " + String(airCraft.longitude) + " º"
        latTitleLabel.text = "Широта: " + String(airCraft.longitude) + " º"
        
        let observers = presenter.getObservers()
        if isFirstStationVisible {
            firstStationLabel.text = observers[0].name + ": да"
        } else {
            firstStationLabel.text = observers[0].name + ": нет"
        }
        
        if isSecondStationVisible {
            secondStationLabel.text = observers[1].name + ": да"
        } else {
            secondStationLabel.text = observers[1].name + ": нет"
        }
        
        if isThirdStationVisible {
            thirdStationLabel.text = observers[2].name + ": да"
        } else {
            thirdStationLabel.text = observers[2].name + ": нет"
        }
        
        if isFortyStationVisible {
            fortyStationLabel.text = observers[3].name + ": да"
        } else {
            fortyStationLabel.text = observers[3].name + ": нет"
        }
    }
    
    private func setupStationLabels() {
        guard let presenter = presenter else { return }
        let observers = presenter.getObservers()
        
        firstStationLabel.text = observers[0].name
        secondStationLabel.text = observers[1].name
    }
    
    private func setupView() {
        backView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        view.backgroundColor = .white
        
        view.addSubviews(backView)
        backView.addSubviews(longTitleLabel,
                             latTitleLabel,
                             passesLabel,
                             underPassesLineView,
                             firstStationLabel,
                             secondStationLabel,
                             thirdStationLabel,
                             fortyStationLabel,
                             imageView)
    }
    
    private func setupNavigationItem() {
        title = airCraft.name
    }
    
    private func setupLayouts() {
        backView.pin
            .all()
        longTitleLabel.pin
            .start(LayoutConstants.horizontalOffset)
            .top(view.pin.safeArea.top)
            .marginTop(LayoutConstants.horizontalOffset)
            .end(LayoutConstants.textEndOffset)
            .sizeToFit(.width)
        latTitleLabel.pin
            .start(LayoutConstants.horizontalOffset)
            .top(to: longTitleLabel.edge.bottom)
            .marginTop(LayoutConstants.verticalOffset)
            .end(LayoutConstants.textEndOffset)
            .sizeToFit(.width)
        passesLabel.pin
            .top(to: latTitleLabel.edge.bottom)
            .start(LayoutConstants.horizontalOffset)
            .end(LayoutConstants.textEndOffset)
            .marginTop(LayoutConstants.verticalOffset)
            .sizeToFit(.width)
        
        let passesWidth = passesLabel.intrinsicContentSize.width
        
        underPassesLineView.pin
            .top(to: passesLabel.edge.bottom)
            .marginTop(1)
            .start(to: passesLabel.edge.start)
            .width(passesWidth)
            .height(2)
        firstStationLabel.pin
            .start(LayoutConstants.horizontalOffset)
            .top(to: underPassesLineView.edge.bottom)
            .marginTop(LayoutConstants.verticalOffset)
            .end(LayoutConstants.textEndOffset)
            .height(40)
        secondStationLabel.pin
            .top(to: firstStationLabel.edge.bottom)
            .start(LayoutConstants.horizontalOffset)
            .end(LayoutConstants.textEndOffset)
            .marginTop(LayoutConstants.verticalOffset)
            .height(40)
        thirdStationLabel.pin
            .top(to: secondStationLabel.edge.bottom)
            .start(LayoutConstants.horizontalOffset)
            .end(20)
            .marginTop(LayoutConstants.verticalOffset)
            .height(40)
        fortyStationLabel.pin
            .top(to: thirdStationLabel.edge.bottom)
            .start(LayoutConstants.horizontalOffset)
            .end(20)
            .marginTop(LayoutConstants.verticalOffset)
            .height(40)
        imageView.pin
            .top(view.pin.safeArea.top)
            .marginTop(LayoutConstants.horizontalOffset)
            .end(LayoutConstants.horizontalOffset)
            .size(LayoutConstants.imageSize)
    }
}

//MARK: - Обновление UI
extension DetailAircraftViewController: DetailPresenterOutput {
    func updateUI() {
        guard let presenter = presenter else { return }
        airCraft = presenter.getAirCraft()
        let passes = presenter.getPasses()
        
        if passes.count == 4 {
            if passes[0].passesCount > 0 {
                isFirstStationVisible = true
            } else {
                isFirstStationVisible = false
            }
            
            if passes[1].passesCount > 0 {
                isSecondStationVisible = true
            } else {
                isSecondStationVisible = false
            }
            
            if passes[2].passesCount > 0 {
                isThirdStationVisible = true
            } else {
                isThirdStationVisible = false
            }
            
            if passes[3].passesCount > 0 {
                isFortyStationVisible = true
            } else {
                isFortyStationVisible = false
            }
        }
        
        setupText()
    }
}

//MARK: - Делегаты выбора станции
extension DetailAircraftViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let presenter = presenter else { return "" }
        let observers = presenter.getObservers()
        return observers[row].name
    }
}

extension DetailAircraftViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.getObservers().count
    }
}

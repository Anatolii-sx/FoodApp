//
//  MainPresenter.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 16.10.2022.
//

import Foundation

// MARK: - MainPresenterProtocol (Connection View -> Presenter)
protocol MainPresenterProtocol {
    var banners: [String] { get }
    var foodTypes: [String] { get }
    var dishes: [[Dish]] { get }
    var selectedFoodType: Int { get }
    init(view: MainViewControllerProtocol)
    func getMenu()
    func foodTypeTapped(_ index: Int)
    func userScrolling(_ visibleSection: Int)
}

class MainPresenter: MainPresenterProtocol {

    // MARK: - Public Properties
    var banners = [
        "Баннер_1",
        "Баннер_2"
    ]
    
    var foodTypes = [
         "Пицца",
         "Бургеры",
         "Сендвичи",
         "Десерты",
         "Напитки"
     ]

    var dishes: [[Dish]] = []
    var selectedFoodType = 0

    // MARK: - Private Properties
    private unowned let view: MainViewControllerProtocol

    // MARK: - Realization MainPresenterProtocol Init (Connection View -> Presenter)
    required init(view: MainViewControllerProtocol) {
        self.view = view
    }

    func foodTypeTapped(_ index: Int) {
        selectedFoodType = index
        view.updateFoodTypeCollectionView()
        view.scrollToSection(selectedFoodType)
    }

    func userScrolling(_ visibleSection: Int) {
        selectedFoodType = visibleSection
        view.updateFoodTypeCollectionView()
    }
}

// MARK: - Getting Data (Network)
extension MainPresenter {
    func getMenu() {
        setEmptyMenu()
        for (index, _) in NetworkManager.shared.urls.enumerated() {
            NetworkManager.shared.downloadDishes(url: NetworkManager.shared.urls[index]) { result in
                switch result {
                case .success(let dishes):
                    self.dishes[index] = dishes
                    self.view.updateTableViewSections(index)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func setEmptyMenu() {
        let emptyDish = Dish(id: nil, name: nil, dsc: nil, price: nil, rate: nil, img: nil)
        for _ in 0..<NetworkManager.shared.urls.count {
            dishes.append([emptyDish])
        }
    }
}

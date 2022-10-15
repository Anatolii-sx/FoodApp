//
//  MainViewController.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 13.10.2022.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet private weak var headerViewTopConstraint: NSLayoutConstraint!
    
    private var foodTypes = [
        "Пицца",
        "Бургеры",
        "Сендвичи",
        "Десерты",
        "Напитки"
    ]
    
    private var banners = [
        "Баннер_1",
        "Баннер_2"
    ]

    private var dishes: [[Dish]] = []
    private var selectedFoodType = 0

    @IBOutlet private weak var bannerCollectionView: UICollectionView!
    @IBOutlet private weak var foodTypeCollectionView: UICollectionView!
    @IBOutlet private weak var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFoodTypeCollectionView()
        setupMenuTableView()
        getMenu()
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    private func setupFoodTypeCollectionView() {
        bannerCollectionView.dataSource = self
        bannerCollectionView.delegate = self
        foodTypeCollectionView.dataSource = self
        foodTypeCollectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == bannerCollectionView ? banners.count : foodTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        // Banners
        if collectionView == bannerCollectionView {
            guard let bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as? BannerCell else {
                return UICollectionViewCell()
            }
            
            let banner = banners[indexPath.row]
            bannerCell.configure(banner: banner)
            cell = bannerCell
        
        // Food Types
        } else if collectionView == foodTypeCollectionView {
            guard let foodTypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodTypeCell", for: indexPath) as? FoodTypeCell else {
                return UICollectionViewCell()
            }
            
            let foodType = foodTypes[indexPath.row]
            foodTypeCell.configure(
                foodType: foodType,
                isSelected: selectedFoodType == indexPath.row ? true : false
            )
            cell = foodTypeCell
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == foodTypeCollectionView {
            selectedFoodType = indexPath.row
            collectionView.reloadData()
            let indexPathTV = IndexPath(row: 0, section: selectedFoodType)
            menuTableView.scrollToRow(at: indexPathTV, at: .top, animated: true)
        } else if collectionView == bannerCollectionView {
            performSegue(withIdentifier: "FromBannerToDescription", sender: nil)
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    private func setupMenuTableView() {
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dishes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dishes[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuCell else {
            return UITableViewCell()
        }
        
        let dish = dishes[indexPath.section][indexPath.row]
        cell.configure(dish: dish)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FromMenuToDescription", sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if menuTableView == scrollView {
            let y = scrollView.contentOffset.y
            
            let swipingDown = y <= 0
            let shouldSnap = y > 30
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                self.bannerCollectionView.alpha = swipingDown ? 1 : 0
                
                self.headerViewTopConstraint.constant = shouldSnap
                ? -(self.bannerCollectionView.frame.height + 44)
                : 0
                
                self.view.layoutIfNeeded()
            }
            
            // Апдейт выбранной группы меню при скролле
            let visibleIndices = menuTableView.indexPathsForVisibleRows ?? []
            let lowestVisibleSection = visibleIndices.map({$0.section}).min() ?? 0
            selectedFoodType = lowestVisibleSection
            foodTypeCollectionView.reloadData()
        }
    }
}

extension MainViewController {
    private func getMenu() {
        setEmptyMenu()
        for (index, _) in NetworkManager.shared.urls.enumerated() {
            NetworkManager.shared.downloadDishes(url: NetworkManager.shared.urls[index]) { result in
                switch result {
                case .success(let dishes):
                    self.dishes[index] = dishes
                    self.menuTableView.reloadSections([index], with: .automatic)
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


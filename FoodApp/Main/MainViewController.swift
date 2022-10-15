//
//  MainViewController.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 13.10.2022.
//

import UIKit

// MARK: - MainViewControllerProtocol (Connection Presenter -> View)
protocol MainViewControllerProtocol: AnyObject {
    func updateTableViewSections(_ index: Int)
    func scrollToSection(_ section: Int)
    func updateFoodTypeCollectionView()
}

class MainViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var bannerCollectionView: UICollectionView!
    @IBOutlet private weak var foodTypeCollectionView: UICollectionView!
    @IBOutlet private weak var menuTableView: UITableView!
    @IBOutlet private weak var headerViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    private var presenter: MainPresenterProtocol!
    
    // MARK: - Methods Of ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainPresenter(view: self)
        setupCollectionsView()
        setupMenuTableView()
        presenter.getMenu()
    }
}

// MARK: - Banners and Food Types (Collection View DataSource and Delegate)
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    private func setupCollectionsView() {
        bannerCollectionView.dataSource = self
        bannerCollectionView.delegate = self
        foodTypeCollectionView.dataSource = self
        foodTypeCollectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == bannerCollectionView ? presenter.banners.count : presenter.foodTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        // Banners
        if collectionView == bannerCollectionView {
            guard let bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as? BannerCell else {
                return UICollectionViewCell()
            }
            
            let banner = presenter.banners[indexPath.row]
            bannerCell.configure(banner: banner)
            cell = bannerCell
        
        // Food Types
        } else if collectionView == foodTypeCollectionView {
            guard let foodTypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodTypeCell", for: indexPath) as? FoodTypeCell else {
                return UICollectionViewCell()
            }
            
            let foodType = presenter.foodTypes[indexPath.row]
            foodTypeCell.configure(
                foodType: foodType,
                isSelected: presenter.selectedFoodType == indexPath.row ? true : false
            )
            cell = foodTypeCell
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == foodTypeCollectionView {
            presenter.foodTypeTapped(indexPath.row)
        } else if collectionView == bannerCollectionView {
            performSegue(withIdentifier: "FromBannerToDescription", sender: nil)
        }
    }
}

// MARK: - Menu (Table View DataSource and Delegate)
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    private func setupMenuTableView() {
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.dishes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.dishes[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuCell else {
            return UITableViewCell()
        }
        let dish = presenter.dishes[indexPath.section][indexPath.row]
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
            let visibleSection = visibleIndices.map({$0.section}).min() ?? 0
            presenter.userScrolling(visibleSection)
        }
    }
}

// MARK: - Realization MainViewControllerProtocol Methods (Connection Presenter -> View)
extension MainViewController: MainViewControllerProtocol {
    func updateFoodTypeCollectionView() {
        foodTypeCollectionView.reloadData()
    }

    func scrollToSection(_ section: Int) {
        let indexPathTV = IndexPath(row: 0, section: section)
        menuTableView.scrollToRow(at: indexPathTV, at: .top, animated: true)
    }
    
    func updateTableViewSections(_ index: Int) {
        menuTableView.reloadSections([index], with: .automatic)
    }
}


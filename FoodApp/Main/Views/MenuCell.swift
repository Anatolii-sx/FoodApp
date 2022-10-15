//
//  MenuCell.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 14.10.2022.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet private weak var picture: FoodImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priceView: UIView!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var activityIndicatorPicture: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        priceView.layer.borderWidth = 1
        priceView.layer.borderColor = #colorLiteral(red: 1, green: 0.3348149955, blue: 0.4859694839, alpha: 1)
        picture.layer.cornerRadius = picture.frame.height / 2
        picture.layer.masksToBounds = true
    }
    
    func configure(dish: Dish) {
        activityIndicatorPicture.startAnimating()
        titleLabel.text = dish.name
        descriptionLabel.text = dish.dsc
        priceLabel.text = "\(Int(dish.price?.rounded(.up) ?? 0)) p"
        picture.fetchImage(from: dish.img ?? "") {
            self.activityIndicatorPicture.stopAnimating()
            self.activityIndicatorPicture.isHidden = true
        }
    }
}

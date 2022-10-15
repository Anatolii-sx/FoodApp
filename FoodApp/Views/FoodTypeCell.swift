//
//  FoodTypeCell.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 15.10.2022.
//

import UIKit

class FoodTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var foodTypeView: UIView!
    @IBOutlet weak var foodTypeLabel: UILabel!
    
    func configure(foodType: String, isSelected: Bool) {
        foodTypeLabel.alpha = isSelected ? 1 : 0.4
        foodTypeView.layer.borderWidth = isSelected ? 0 : 1
        foodTypeView.layer.borderColor = isSelected ? #colorLiteral(red: 1, green: 0.3348149955, blue: 0.4862745098, alpha: 0.2048841059) : #colorLiteral(red: 1, green: 0.3348149955, blue: 0.4859694839, alpha: 0.3985927152)
        foodTypeView.backgroundColor = isSelected ? #colorLiteral(red: 1, green: 0.3348149955, blue: 0.4862745098, alpha: 0.2048841059) : .clear

        foodTypeLabel.font = isSelected
        ? UIFont(name: "SFUIDisplay-Bold", size: 13)
        : UIFont(name: "SFUIDisplay-Regular", size: 13)

        foodTypeLabel.text = foodType
    }
}

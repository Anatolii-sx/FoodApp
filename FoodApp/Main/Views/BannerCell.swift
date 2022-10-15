//
//  BannerCell.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 15.10.2022.
//

import UIKit

class BannerCell: UICollectionViewCell {
    @IBOutlet weak var bannerPicture: UIImageView!
    
    func configure(banner: String) {
        bannerPicture.image = UIImage(named: banner)
    }
}

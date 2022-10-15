//
//  Dish.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 15.10.2022.
//

import Foundation

struct Dish: Decodable {
    let id: String?
    let name: String?
    let dsc: String?
    let price: Double?
    let rate: Double?
    let img: String?
}

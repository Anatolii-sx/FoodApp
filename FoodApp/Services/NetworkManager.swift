//
//  NetworkManager.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 15.10.2022.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

enum FoodType: String {
    case pizzas = "pizzas"
    case burgers = "burgers"
    case sandwiches = "sandwiches"
    case desserts = "desserts"
    case drinks = "drinks"
}

class NetworkManager {
    static let shared = NetworkManager()

    var urls = [
        "https://ig-food-menus.herokuapp.com/\(FoodType.pizzas)?_page=1&_limit=4",
        "https://ig-food-menus.herokuapp.com/\(FoodType.burgers)?_page=3&_limit=4",
        "https://ig-food-menus.herokuapp.com/\(FoodType.sandwiches)?_page=3&_limit=4",
        "https://ig-food-menus.herokuapp.com/\(FoodType.desserts)?_page=2&_limit=4",
        "https://ig-food-menus.herokuapp.com/\(FoodType.drinks)?_page=1&_limit=4"
    ]
    
    private init() {}
    
    func downloadDishes(url: String, completion: @escaping(Result<[Dish], NetworkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let dishes = try JSONDecoder().decode([Dish].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(dishes))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func getPicture(from url: URL, completion: @escaping(Data, URLResponse) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let response = response else {
                print(error?.localizedDescription ?? "No error description")
                return
            }

            guard url == response.url else { return }
            
            DispatchQueue.main.async {
                completion(data, response)
            }
        }.resume()
    }
}

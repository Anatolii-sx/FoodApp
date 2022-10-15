//
//  FoodImageView.swift
//  FoodApp
//
//  Created by Анатолий Миронов on 15.10.2022.
//

import UIKit

class FoodImageView: UIImageView {

    func fetchImage(from url: String, completion: @escaping() -> Void) {
        guard let url = URL(string: url) else { return }

        // Используем изображение из кеша, если оно там есть
        if let cachedImage = getCachedImage(from: url) {
            print("IMAGE FROM CASH")
            image = cachedImage
            completion()
            return
        }

        // Если изображения нет, то грузим его из сети
        NetworkManager.shared.getPicture(from: url) { data, response in
            print("NETWORK GET IMAGE")
            self.image = UIImage(data: data)
            self.saveDataToCache(with: data, and: response)
            completion()
        }
    }

    private func saveDataToCache(with data: Data, and response: URLResponse) {
        guard let url = response.url else { return }
        let request = URLRequest(url: url)
        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: request)
        print("SAVE IMAGE TO CASH")
    }

    private func getCachedImage(from url: URL) -> UIImage? {
        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            return UIImage(data: cachedResponse.data)
        }
        return nil
    }

}

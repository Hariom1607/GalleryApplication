//
//  NetworkManager.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchImages(page: Int, completion: @escaping (Result<[ImageModel], Error>) -> Void) {
        
        guard let url = URL(string: "\(Constants.baseURL)?page=\(page)&limit=\(Constants.pageLimit)") else {
            return
        }
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print(error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let images = try JSONDecoder().decode([ImageModel].self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(images))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

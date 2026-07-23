//
//  ImageStorageManager.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import UIKit

final class ImageStorageManager {

    static let shared = ImageStorageManager()

    private init() {}

    // MARK: Save Image

    func saveImage(from imageURL: String,
                   imageId: String,
                   completion: @escaping (String?) -> Void) {

        guard let url = URL(string: imageURL) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in

            guard let data = data,
                  let image = UIImage(data: data) else {

                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let fileName = "\(imageId).jpg"

            guard let localURL = self.getDocumentsDirectory()?
                .appendingPathComponent(fileName) else {

                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let jpegData = image.jpegData(compressionQuality: 1.0) else {

                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            do {

                try jpegData.write(to: localURL)

                DispatchQueue.main.async {
                    completion(localURL.path)
                }

            } catch {

                DispatchQueue.main.async {
                    completion(nil)
                }

            }

        }.resume()

    }
    
    func getLocalURL(for fileName: String) -> URL? {
        return getDocumentsDirectory()?.appendingPathComponent(fileName)
    }

    // MARK: Load Image

    func loadImage(from localPath: String) -> UIImage? {

        return UIImage(contentsOfFile: localPath)

    }

    // MARK: Documents Directory

    private func getDocumentsDirectory() -> URL? {

        FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask).first

    }

}

//
//  DatabaseManager.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import Foundation
import CoreData
import UIKit

final class DatabaseManager {

    static let shared = DatabaseManager()

    private init() {}

    // MARK: Context

    private var context: NSManagedObjectContext {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext

    }

    // MARK: Save Image

    func saveImage(_ image: ImageModel) {
        
        let request: NSFetchRequest<GalleryImage> = GalleryImage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", image.id)
        
        do {
            
            let result = try context.fetch(request)
            
            let galleryImage: GalleryImage
            
            if let existing = result.first {
                
                galleryImage = existing
                
            } else {
                
                galleryImage = GalleryImage(context: context)
                
            }
            
            galleryImage.id = image.id
            galleryImage.author = image.author
            galleryImage.imageURL = image.download_url
            galleryImage.localImagePath = image.localImagePath
            
            try context.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: Fetch Images

    func fetchImages() -> [ImageModel] {

        let request: NSFetchRequest<GalleryImage> = GalleryImage.fetchRequest()

        do {

            let result = try context.fetch(request)

            return result.map {

                ImageModel(
                    id: $0.id ?? "",
                    author: $0.author ?? "",
                    download_url: $0.imageURL ?? "",
                    localImagePath: $0.localImagePath
                )

            }

        } catch {

            print(error.localizedDescription)

            return []

        }

    }

    // MARK: Check Existing Image

    func imageExists(id: String) -> Bool {

        let request: NSFetchRequest<GalleryImage> = GalleryImage.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", id)

        do {

            return try context.count(for: request) > 0

        } catch {

            return false

        }

    }

    // MARK: Delete All

    func deleteAllImages() {

        let request: NSFetchRequest<NSFetchRequestResult> = GalleryImage.fetchRequest()

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {

            try context.execute(deleteRequest)

            try context.save()

        } catch {

            print(error.localizedDescription)

        }

    }

}

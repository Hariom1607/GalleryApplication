//
//  GalleryViewModel.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import Foundation

final class GalleryViewModel {
    
    private(set) var images: [ImageModel] = []
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMoreData = true
    
    var onDataUpdated: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    func fetchImages() {
        
        guard !isLoading else { return }
        guard hasMoreData else { return }
        
        // Show cached data on first load
        if images.isEmpty {
            loadOfflineImages()
        }
        
        isLoading = true
        onLoadingStateChanged?(true)
        
        NetworkManager.shared.fetchImages(page: currentPage) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let newImages):
                
                if newImages.isEmpty {
                    self.hasMoreData = false
                    self.isLoading = false
                    self.onLoadingStateChanged?(false)
                    return
                }
                // Advance page BEFORE saving, so any subsequent scroll
                // triggers the correct next page fetch
                self.currentPage += 1
                self.saveImages(newImages)
                
            case .failure:
                self.isLoading = false
                self.onLoadingStateChanged?(false)
                print("Network failed — showing cached images")
                
            }
        }
    }
    
    func loadMoreIfNeeded(currentIndex: Int) {
        let threshold = max(images.count - 4, 0)
        if currentIndex >= threshold {
            fetchImages()
        }
    }
    
    private func loadOfflineImages() {
        
        images = DatabaseManager.shared.fetchImages()
        
        // Restore the correct next page based on how many images are cached
        if !images.isEmpty {
            currentPage = (images.count / Constants.pageLimit) + 1
        }
        
        print("Offline images loaded: \(images.count), next page: \(currentPage)")
        
        onDataUpdated?()
    }
    
    private func saveImages(_ apiImages: [ImageModel]) {
        
        // Separate new images (not yet in DB) from already-cached ones
        let newImages = apiImages.filter {
            !DatabaseManager.shared.imageExists(id: $0.id)
        }
        
        // If every image on this page is already cached, just refresh the UI
        // and release the loading lock — no downloads needed
        guard !newImages.isEmpty else {
            self.images = DatabaseManager.shared.fetchImages()
            self.isLoading = false
            self.onLoadingStateChanged?(false)
            self.onDataUpdated?()
            return
        }
        
        // Download and persist only the new images
        let group = DispatchGroup()
        
        for image in newImages {
            group.enter()
            ImageStorageManager.shared.saveImage(
                from: image.download_url,
                imageId: image.id
            ) { localPath in
                defer { group.leave() }
                
                guard let localPath else { return }
                
                var updated = image
                updated.localImagePath = localPath
                DatabaseManager.shared.saveImage(updated)
            }
        }
        
        // Called once — after ALL downloads for this page complete
        group.notify(queue: .main) {
            self.images = DatabaseManager.shared.fetchImages()
            self.isLoading = false
            self.onLoadingStateChanged?(false)
            self.onDataUpdated?()
        }
    }
}

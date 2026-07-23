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
        
        // Always show cached data first
        if images.isEmpty {
            loadOfflineImages()
        }
        
        isLoading = true
        onLoadingStateChanged?(true)
        
        NetworkManager.shared.fetchImages(page: currentPage) { [weak self] result in
            
            guard let self = self else { return }
            
            self.isLoading = false
            self.onLoadingStateChanged?(false)
            
            switch result {
                
            case .success(let newImages):
                
                if newImages.isEmpty {
                    self.hasMoreData = false
                    return
                }
                self.saveImages(newImages)
                
            case .failure:
                print("Showing cached images")
                
            }
        }
    }
    
    func loadMoreIfNeeded(currentIndex: Int) {
        
        if currentIndex >= images.count - 4 {
            fetchImages()
        }
    }
    
    private func loadOfflineImages() {
        
        images = DatabaseManager.shared.fetchImages()
        
        currentPage = (images.count / Constants.pageLimit) + 1
        
        print("Offline:", images.count)
        print("Next Page:", currentPage)
        
        onDataUpdated?()
        
    }
    
    private func saveImages(_ apiImages: [ImageModel]) {
        
        let group = DispatchGroup()
        var anyNewImageSaved = false
        
        for image in apiImages {
            if DatabaseManager.shared.imageExists(id: image.id) {
                continue
            }
            anyNewImageSaved = true
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
        
        group.notify(queue: .main) {
            // Advance to the next page only after all images from this page are processed
            self.currentPage += 1
            
            if anyNewImageSaved {
                // Refresh the image list from DB and notify the view
                self.images = DatabaseManager.shared.fetchImages()
                self.onDataUpdated?()
            }
            
            if !anyNewImageSaved {
                // All images on this page already existed — mark no more new data
                // to avoid fetching the same page repeatedly, then try the next page
                self.hasMoreData = self.currentPage <= 100 // picsum supports up to ~100 pages
                self.fetchImages()
            }
        }
    }
}

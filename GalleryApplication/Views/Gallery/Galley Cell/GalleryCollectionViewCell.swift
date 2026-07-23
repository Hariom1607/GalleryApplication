//
//  GalleryCollectionViewCell.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import UIKit
import Kingfisher

class GalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgGallery: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgGallery.layer.cornerRadius = 14
        imgGallery.contentMode = .scaleAspectFill
        imgGallery.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgGallery.kf.cancelDownloadTask()
        imgGallery.image = nil
    }
    
    func configure(with image: ImageModel) {
        // OFFLINE IMAGE — resolve relative filename or last path component dynamically against current Documents directory
        if let pathOrName = image.localImagePath {
            let fileName = (pathOrName as NSString).lastPathComponent
            if let localURL = ImageStorageManager.shared.getLocalURL(for: fileName),
               FileManager.default.fileExists(atPath: localURL.path) {
                imgGallery.image = UIImage(contentsOfFile: localURL.path)
                return
            }
        }
        
        // ONLINE IMAGE
        guard let url = URL(string: image.download_url) else {
            imgGallery.image = UIImage(systemName: "photo")
            return
        }
        
        imgGallery.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo")
        )
    }
}

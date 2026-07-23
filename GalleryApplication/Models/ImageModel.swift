//
//  ImageModel.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import Foundation

struct ImageModel:Codable {
    
    let id: String
    let author: String
    let download_url: String
    var localImagePath: String?
}

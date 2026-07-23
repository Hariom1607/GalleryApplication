//
//  GalleryViewController.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import Foundation
import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collGallery: UICollectionView!
    private let viewModel = GalleryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collGallery.register(UINib(nibName: "GalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCollectionViewCell")
        bindViewModel()
        viewModel.fetchImages()
        setupNavigationBar()
    }
    
    private func bindViewModel() {
        
        viewModel.onDataUpdated = { [weak self] in
            self?.collGallery.reloadData()
        }
        
        viewModel.onError = { message in
            print(message)
        }
    }
    
    private func setupNavigationBar() {
        title = "Gallery"

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil

        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
        profileButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = profileButton
    }
    
    @objc private func profileButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension GalleryViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collGallery.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as? GalleryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModel.images[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 2
        
        return CGSize(width: width, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.row)
    }
}

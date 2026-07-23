//
//  ProfileViewController.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import Foundation
import UIKit
import GoogleSignIn
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        setupUI()
        loadUserData()
        
    }
    
    
    private func setupUI() {
        imgUser.layer.cornerRadius = 50
        imgUser.clipsToBounds = true
        btnLogout.layer.cornerRadius = 12
    }
    
    private func loadUserData() {
        lblName.text = "Name : \(UserDefaults.standard.string(forKey: "UserName") ?? "N/A")"
        lblEmail.text = "Email : \(UserDefaults.standard.string(forKey: "UserEmail") ?? "N/A")"
        
        if let imageURLString = UserDefaults.standard.string(forKey: "image"),
           let url = URL(string: imageURLString) {
            loadProfileImage(from: url)
        }
    }
    
    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imgUser.image = image
            }
        }.resume()
    }
    
    @IBAction func btnLogoutAction(_ sender: Any) {
        showLogoutConfirmation()
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }
    
    private func performLogout() {
        // 1. Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        // 2. Sign out from Firebase
        do {
            try Auth.auth().signOut()
        } catch {
            print("Firebase sign out error: \(error.localizedDescription)")
        }
        // 3. Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "UserName")
        UserDefaults.standard.removeObject(forKey: "UserEmail")
        UserDefaults.standard.removeObject(forKey: "image")
        // 4. Navigate back to Login screen
        navigateToLogin()
    }
    
    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(
            withIdentifier: "LoginViewController"
        ) as? LoginViewController else { return }
        // Replace the entire navigation stack with LoginViewController
        navigationController?.setViewControllers([loginVC], animated: true)
    }
}

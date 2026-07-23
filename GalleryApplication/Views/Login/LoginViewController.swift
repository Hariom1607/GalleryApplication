//
//  LoginViewController.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 21/07/26.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var btnGoogleSignIn: UIButton!
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupGoogleButton()
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            navigateToGallery()
            return
        }
        setupBindings()
    }
    
    @IBAction func btnGoogleLogInAction(_ sender: Any) {
        viewModel.signIn(from: self)
    }
    
    private func setupGoogleButton() {
        
        btnGoogleSignIn.layer.cornerRadius = 24
        btnGoogleSignIn.layer.borderWidth = 1
        btnGoogleSignIn.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupBindings() {

        viewModel.loginSuccess = { [weak self] user in

            print(user.name)
            print(user.email)
            print(user.profileImageURL)

            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            let vc = storyboard.instantiateViewController(withIdentifier: "GalleryViewController")

            self?.navigationController?.setViewControllers([vc], animated: true)

        }

        viewModel.loginFailure = { [weak self] message in

            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))

            self?.present(alert, animated: true)

        }
    }
    
    private func navigateToGallery() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GalleryViewController")
        navigationController?.setViewControllers([vc], animated: false)
    }
}


//
//  LoginViewModel.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import UIKit

class LoginViewModel {
    
    private let authService = GoogleAuthService()
    
    var loginSuccess: ((User) -> Void)?
    var loginFailure: ((String) -> Void)?
    
    func signIn(from controller: UIViewController) {
        authService.signIn(from: controller) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
                
            case .success(let user):
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(user.name, forKey: "UserName")
                UserDefaults.standard.set(user.email, forKey: "UserEmail")
                UserDefaults.standard.set(user.profileImageURL, forKey: "image")
                
                self.loginSuccess?(user)
                
            case .failure(let error):
                self.loginFailure?(error.localizedDescription)
            }
        }
    }
}

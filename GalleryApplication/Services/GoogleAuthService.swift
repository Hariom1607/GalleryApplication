//
//  GoogleAuthService.swift
//  GalleryApplication
//
//  Created by Hariom Sharma on 22/07/26.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class GoogleAuthService {
    
    func signIn(from viewController: UIViewController, completion: @escaping(Result<User, Error>) -> Void) {
        guard let clientId = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        let configuration = GIDConfiguration(clientID: clientId)
        GIDSignIn.sharedInstance.configuration = configuration
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let appUser = User(name: user.profile?.name ?? "", email: user.profile?.email ?? "", profileImageURL: user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "")
                
                completion(.success(appUser))
            }
        }
    }
}

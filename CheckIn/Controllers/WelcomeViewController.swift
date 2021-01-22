//
//  WelcomeViewController.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 10.1.21.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import AuthenticationServices
import SVProgressHUD


class WelcomeViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            getLocalUserData(uid: user.uid)
            return
        }
    }
    
    
    func userDidLogin(token: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let authResult = authResult {
                let user = authResult.user
                print(user)
                self.getLocalUserData(uid: user.uid)
            }
        }
    }
    
    func getLocalUserData(uid: String) {
        SVProgressHUD.show()
        DataStore.shared.getUser(uid: uid) { (user, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if let user = user {
                DataStore.shared.localUser = user
                self.continueToHomeScreen()
            }
        }
    }
    
    func continueToHomeScreen() {
        goHome()
    }
    
    @IBAction func signInButton(_ sender: UIButton) {
        performSegue(withIdentifier: "LogIn", sender: nil)
    }
    
    @IBAction func createAccountButton(_ sender: UIButton) {
        performSegue(withIdentifier: "Register", sender: nil)
        
    }
    @IBAction func facebookButton(_ sender: UIButton) {
        let manager = LoginManager()
        manager.logIn(permissions: ["public_profile","email"], from: self) { (loginResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let result = loginResult, !result.isCancelled, let token = result.token {
                    self.userDidLogin(token: token.tokenString)
                    self.goHome()
                } else {
                    print("User Canceled flow")
                }
            }
        }
    }
    
    func goHome() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        navigationController?.pushViewController(controller, animated: true)
    }
}

//let loginManager = LoginManager()
//        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
//            if let error = error {
//                print("Failed to login: \(error.localizedDescription)")
//                return
//            }
//            guard let accessToken = AccessToken.current else {
//                print("Failed to get access token")
//                return
//            }
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//            Auth.auth().signIn(with: credential) { (user, error) in
//                if let error = error {
//                    print("Login error: \(error.localizedDescription)")
//                    let alertController = UIAlertController(title: "Login error", message: error.localizedDescription, preferredStyle: .alert)
//                    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(alertAction)
//                    self.present(alertController, animated: true, completion: nil)
//                    return
//                } else {
//                    if Auth.auth().currentUser != nil {
//                        self.performSegue(withIdentifier: "Home", sender: nil)
//                    }
//                }
//            }
//        }

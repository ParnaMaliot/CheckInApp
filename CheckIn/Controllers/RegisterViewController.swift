//
//  RegisterViewController.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 11.1.21.
//

import UIKit
import SVProgressHUD
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        guard let email = emailTxtField.text, email != "" else {
            showErrorWith(title: "Error", msg: "Please enter your email")
            return
        }
        guard let pass = passwordTxtField.text, pass != "" else {
            showErrorWith(title: "Error", msg: "Please enter password")
            return
        }
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid email")
            return
        }
        guard pass.count >= 6 else {
            showErrorWith(title: "Error", msg: "Password must contain at least 6 characters")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: pass) { (authResult, error) in
            if let error = error {
                let specificError = error as NSError
               
                if specificError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.showErrorWith(title: "Error", msg: "Email already in use!")
                    return
                }
                if specificError.code == AuthErrorCode.weakPassword.rawValue {
                    self.showErrorWith(title: "Error", msg: "Your password is too weak")
                    return
                }
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if let authResult = authResult {
                self.saveUser(uid: authResult.user.uid)
            }
        }

        guard let localUser = user else {return}

        DataStore.shared.setUserData(user: localUser) { (success, error) in
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if success {
                DataStore.shared.localUser = localUser
            }
        }
    }
    
    func saveUser(uid: String) {
        var user = User(id: uid)
        SVProgressHUD.show()
        user.name = nameTxtField.text
        user.email = emailTxtField.text
        DataStore.shared.setUserData(user: user) { (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if success {
                DataStore.shared.localUser = user
                self.continueToHome()
            }
        }
    }

    func continueToHome() {
        performSegue(withIdentifier: "Home", sender: nil)
    }
    
}

//
//  LogInViewController.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 11.1.21.
//

import UIKit
import SVProgressHUD
import Firebase

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func logInButton(_ sender: UIButton) {
        
        guard let email = emailTxtField.text, email != "" else {
            showErrorWith(title: "Error", msg: "Please enter your email")
            return
        }
        
        guard let pass = password.text, pass != "" else {
            showErrorWith(title: "Error", msg: "Please enter password")
            return
        }
        
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid email")
            return
        }
        
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: pass) { (authResult, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                let specificError = error as NSError
               
                if specificError.code == AuthErrorCode.invalidEmail.rawValue && specificError.code == AuthErrorCode.wrongPassword.rawValue {
                    self.showErrorWith(title: "Error", msg: "Incorect email or password")
                    return
                }
                if specificError.code == AuthErrorCode.userDisabled.rawValue {
                    self.showErrorWith(title: "Error", msg: "You account was disabled")
                    return
                }
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            
            if let authResult = authResult {
                self.getLocalUserData(uid: authResult.user.uid)
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
                self.continuteToHome()
                return
            }
        }
    }
    
    func continuteToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        present(controller, animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
}

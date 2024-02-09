//
//  ViewController.swift
//  FirebaseInstaClone
//
//  Created by Sarper Kececi on 25.09.2023.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {
    
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        guard let username = usernameText.text, !username.isEmpty,
              let password = passwordText.text, !password.isEmpty else {
            alertMessage(title: "Error", message: "Username / Password cannot be empty")
            return
        }

        Auth.auth().signIn(withEmail: username, password: password) { authDataResult, error in
            if let error = error {
                self.alertMessage(title: "Error", message: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                // Giriş başarılı oldu, istediğiniz işlemi yapabilirsiniz.
             
                
            }
        }
    }

    
    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        
        if usernameText.text != nil && passwordText.text != nil {
            Auth.auth().createUser(withEmail: usernameText.text!, password: passwordText.text!) { authData, error in
                if error != nil {
                    self.alertMessage(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
           
        } else {
            alertMessage(title: "Error", message: "Username / Password")
        }
       
        
        
    }
    
    func alertMessage (title : String , message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        
        present(alert, animated: true)
    }
    
    
    
    
}


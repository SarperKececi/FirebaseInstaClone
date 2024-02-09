//
//  SettingsViewController.swift
//  FirebaseInstaClone
//
//  Created by Sarper Kececi on 25.09.2023.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toViewVC", sender: nil)
            
        } catch {
            print("error")
        }
        
    }
    
    
    
}

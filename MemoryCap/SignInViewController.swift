//
//  SignInViewController.swift
//  MemoryCap
//
//  Created by Bao Trinh on 2/20/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var signInSelector: UISegmentedControl!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var isSignIn:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FIRAuth.auth()?.currentUser == nil {
            self.performSegue(withIdentifier: "goToMain", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        switch signInSelector.selectedSegmentIndex
        {
        case 0:
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
            isSignIn = true
        case 1:
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
            isSignIn = false
        default:
            break; 
        }
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        // Make sure email and password fiels are filled
        if let email = emailTextField.text, let password = passwordTextField.text {
            if (isSignIn) {
                // Sign in user
                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion:
                    { (user, error) in
                    // Check that user isn't nil
                        if let u = user {
                            // User found, goto main page
                            self.performSegue(withIdentifier: "goToMain", sender: self)
                        } else {
                            // TODO: check and show error
                        }
                })
            } else {
                // Register user
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion:
                    { (user, error) in
                        // Check that user isn't nil
                        if let u = user {
                            // User found, goto main page
                            self.performSegue(withIdentifier: "goToMain", sender: self)
                        } else {
                            print(error)
                            // TODO: check and show error
                        }
                })
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

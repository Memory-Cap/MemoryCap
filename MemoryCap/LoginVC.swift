//
//  LoginViewController.swift
//  MemoryCap
//
//  Created by Bao Trinh on 4/2/17.
//  Copyright © 2017 Bao Trinh. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: RoundTextField!
    @IBOutlet weak var passwordTextField: RoundTextField!
    @IBOutlet weak var signupButton: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        // Check to see if user already logged in
        if FIRAuth.auth()?.currentUser != nil {
            self.returnToApp()
        }
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let _ = user {
                self.returnToApp()
            }
        }
        
        // email and password text fields
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.emailTextField.returnKeyType = UIReturnKeyType.next
        self.passwordTextField.returnKeyType = UIReturnKeyType.go
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signin(email: String, password: String) {
        // Sign in user
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion:
            { (user, error) in
                // Check that user isn't nil
                if let _ = user {
                    // User found, goto main page
                    self.returnToApp()
                } else {
                    // TODO: check and show error
                }
        })
    }
    
    func register(email: String, password: String) {
        // Register user
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion:
            { (user, error) in
                // Check that user isn't nil
                if let u = user {
                    // User found, goto main page
                    self.returnToApp()
                } else {
                    print(error)
                    // TODO: check and show error
                }
        })
    }
    
    func returnToApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "RootController") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            signin(email: email, password: password)
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField === emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if let email = emailTextField.text, let password = passwordTextField.text {
                signin(email: email, password: password)
            }
        }
        return true
    }
    
    @IBAction func registerLinkPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            register(email: email, password: password)
        }
    }
}

//
//  ViewController.swift
//  Pick A Drive
//
//  Created by Lovish Dogra on 18/05/16.
//  Copyright © 2016 Lovish Dogra. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {
    
    var signupState = true
    
    @IBOutlet var signupLabel: UILabel!
    @IBOutlet var `switch`: UISwitch!
    @IBOutlet var riderLabel: UILabel!
    @IBOutlet var driverLabel: UILabel!
    @IBOutlet var signupBtnLabel: UIButton!
    @IBOutlet var regLabel: UILabel!
    @IBOutlet var loginBtnLabel: UIButton!
    
    @IBOutlet var unameText: UITextField!
    @IBOutlet var passwordText: UITextField!
    
    
    @IBAction func loginBtn(_ sender: AnyObject) {
        
        if signupState == true {
            signupLabel.text = "Login"
            signupBtnLabel.setTitle("Login", for: UIControlState())
            regLabel.text = "Not registered"
            loginBtnLabel.setTitle("Signup", for: UIControlState())
            signupState = false
            
            riderLabel.alpha = 0
            driverLabel.alpha = 0
            `switch`.alpha = 0
        } else {
            signupLabel.text = "Signup"
            signupBtnLabel.setTitle("Signup", for: UIControlState())
            regLabel.text = "Already registered"
            loginBtnLabel.setTitle("Login", for: UIControlState())
            signupState = true
            
            riderLabel.alpha = 1
            driverLabel.alpha = 1
            `switch`.alpha = 1
            
        }
        
    }
    
    @IBAction func signupBtn(_ sender: AnyObject) {
        
        if unameText.text == "" || passwordText.text == "" {
            displayAlert("Missing Field(s)", message: "Username & Password are required")
            
        }
        else {
            if signupState == true {
                let user = PFUser()
                user.username = unameText.text
                user.password = passwordText.text
                user["isDriver"] = `switch`.isOn
                
                user.signUpInBackground{ (succeeded, error) in
                    if let error = error {
                        let errorString = error._userInfo["error"] as! NSString
                        self.displayAlert("Signup Failed", message: errorString as String)
                        
                    } else {
                        if self.`switch`.isOn == true {
                            self.performSegue(withIdentifier: "loginDriver", sender: self)
                            
                        } else{
                            self.performSegue(withIdentifier: "loginRider", sender: self)
                            
                        }
                    }
                }
                
                
            } else{
                PFUser.logInWithUsername(inBackground: unameText.text!, password: passwordText.text!, block: { (user, error) in
                    if let user = user {
                        if user["isDriver"]! as! Bool == true {
                            self.performSegue(withIdentifier: "loginDriver", sender: self)
                            
                        } else{
                            self.performSegue(withIdentifier: "loginRider", sender: self)
                            
                        }
                        
                    } else {
                        let errorString = error!.userInfo["error"] as! NSString
                        self.displayAlert("Login Failed", message: errorString as String)
                        
                    }
                })
            }
        }
        
    }
    
    func displayAlert(_ title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupBtnLabel.layer.cornerRadius = 9
        self.unameText.delegate = self;
        self.passwordText.delegate = self;
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current()?.username != nil {
            if PFUser.current()?["isDriver"]! as! Bool == true {
                self.performSegue(withIdentifier: "loginDriver", sender: self)
                
            } else{
                self.performSegue(withIdentifier: "loginRider", sender: self)
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
}


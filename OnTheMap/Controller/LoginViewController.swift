//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/13.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fbLoginButton = FBSDKLoginButton.init()
        fbLoginButton.center = self.view.center
        self.view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        Loading.startLoading()
        self.enableInputElements(false)
        
        if error != nil {
            self.presentViewController(self.createAlert("Error", message: "Could not login.\nTry again, please😊"), animated: true, completion: nil)
            self.enableInputElements(true)
            Loading.finishLoading()
        } else if result.isCancelled {
            self.enableInputElements(true)
            Loading.finishLoading()
        } else {
            let udacityClient = UdacityClient.sharedInstance
            udacityClient.loginWithFaceBookLogin(result.token.tokenString) { (success, errorString) in
                performUIUpdatesOnMain {
                    self.enableInputElements(true)
                    Loading.finishLoading()
                    if success {
                        self.completeLogin()
                    } else {
                        self.presentViewController(self.createAlert("Error", message: "Could not login.\nTry again, please😊"), animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    @IBAction func pressLogin(sender: AnyObject) {
        
        let udacityClient = UdacityClient.sharedInstance
        
        Loading.startLoading()
        self.enableInputElements(false)
        
        udacityClient.loginWithUsernameAndPassword(self) { (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.completeLogin()
                } else {
                    self.presentViewController(self.createAlert("Error", message: "Invalid username or password.\nTry again, please😊"), animated: true, completion: nil)
                }
                self.enableInputElements(true)
                Loading.finishLoading()
            }
        }
    }
    
    private func enableInputElements(enabled: Bool) {
        self.textFieldUsername.enabled = enabled
        self.textFieldPassword.enabled = enabled
        self.loginButton.enabled = enabled
        self.fbLoginButton.hidden = !enabled
    }
    
    private func completeLogin() {
        self.performSegueWithIdentifier("toMainView", sender: self)
    }

}


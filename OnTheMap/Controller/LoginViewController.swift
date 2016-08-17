//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/13.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    let alertController = UIAlertController.init(title: "Error", message: errorString, preferredStyle: .Alert)
                    let alertAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(alertAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
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
    }
    
    private func completeLogin() {
        self.performSegueWithIdentifier("toMainView", sender: self)
    }

}


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

    // Facebook Login
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        Loading.startLoading()
        self.enableInputElements(false)

        if error != nil {
            self.showAlert(self, title: "Error", message: "Could not login.\nTry again, please😊")
            self.enableInputElements(true)
            Loading.finishLoading()
        } else if result.isCancelled {
            self.enableInputElements(true)
            Loading.finishLoading()
        } else {
            let udacityClient = UdacityClient.sharedInstance
            udacityClient.loginWithFaceBookLogin(result.token.tokenString) {
                (success, errorString) in
                performUIUpdatesOnMain {
                    self.enableInputElements(true)
                    Loading.finishLoading()
                    if success {
                        self.completeLogin()
                    } else {
                        self.showAlert(self, title: "Error", message: "Could not login.\nTry again, please😊")
                    }
                }
            }
        }

    }

    // Facebook Logout
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

    }

    @IBAction func pressLogin(sender: AnyObject) {

        let udacityClient = UdacityClient.sharedInstance

        Loading.startLoading()
        self.enableInputElements(false)

        udacityClient.loginWithUsernameAndPassword(self) {
            (success, errorType) in
            performUIUpdatesOnMain {
                if success {
                    self.completeLogin()
                } else {
                    var message = "Something wrong.."
                    do {
                        throw errorType!
                    } catch UdacityErrors.NoUsername {
                        message = "Email is required"

                    } catch UdacityErrors.NoPassword {
                        message = "Password is required"

                    } catch UdacityErrors.InvalidStatusCode(let response) {
                        print("\(response)")
                        message = "Invalid username or password"

                    } catch UdacityErrors.ResponseError(let error) {
                        message = error!.localizedDescription

                    } catch {
                        print("\(errorType)")

                    }

                    self.showAlert(self, title: "Error", message: message)
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


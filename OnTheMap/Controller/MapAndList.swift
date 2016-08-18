//
//  MapAndList.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/15.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit
import FBSDKLoginKit

protocol MapAndList {
    func openURL(urlString: String)

    func doLogOut()

    func reloadStudentLocations(completionHander: (success:Bool, errorString:String?) -> Void)

    func showInformationPostingView()
}

extension MapAndList where Self: UIViewController {

    func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            showAlert(self, title: "", message: "Invalid URL")
        }
    }

    func doLogOut() {
        let confirmView = UIAlertController.init(title: nil, message: "Do you really want to logout?", preferredStyle: .Alert)
        confirmView.addAction(UIAlertAction.init(title: "Yes", style: .Default, handler: {
            (action) in
            UdacityClient.sharedInstance.logOut()

            // facebook logout
            let fbLoginManager = FBSDKLoginManager.init()
            fbLoginManager.logOut()

            self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
        }))
        confirmView.addAction(UIAlertAction.init(title: "No", style: .Cancel, handler: nil))
        self.presentViewController(confirmView, animated: true, completion: nil)

    }

    func reloadStudentLocations(completionHander: (success:Bool, errorString:String?) -> Void) {
        let parseClient = ParseClient.sharedInstance
        parseClient.getStudentLocations {
            (success, errorString) in
            completionHander(success: success, errorString: errorString)
        }
    }

    func showInformationPostingView() {
        let parseClient = ParseClient.sharedInstance
        if parseClient.myLocations.count > 0 {
            let confirmView = UIAlertController.init(title: nil, message: "You have already posted your location. Would you like to overwrite your current location?", preferredStyle: .Alert)
            confirmView.addAction(UIAlertAction.init(title: "Overwrite", style: .Default, handler: {
                (action) in
                self.performSegueWithIdentifier("toInformationPostingView", sender: self)
            }))
            confirmView.addAction(UIAlertAction.init(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(confirmView, animated: true, completion: nil)
            return
        }
        self.performSegueWithIdentifier("toInformationPostingView", sender: self)
    }

}
//
//  MapAndList.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/15.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit

protocol MapAndList {
    func doLogOut()
    func showInformationPostingView()
}


extension MapAndList where Self: UIViewController {
    
    func openURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            let alertController = UIAlertController(title: "error", message: "Invalid URL", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func doLogOut() {
        UdacityClient.sharedInstance.logOut()
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showInformationPostingView() {
        self.performSegueWithIdentifier("toInformationPostingView", sender: self)
    }
    
}
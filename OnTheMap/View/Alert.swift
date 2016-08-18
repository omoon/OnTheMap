//
//  Alert.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/17.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlert(viewController: UIViewController, title: String?, message: String?) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
        alertView.addAction(action)
        viewController.presentViewController(alertView, animated: true, completion: nil)
    }
}

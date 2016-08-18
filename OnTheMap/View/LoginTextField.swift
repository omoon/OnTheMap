//
//  LoginTextField.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/17.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.borderStyle = .RoundedRect
        self.textColor = UIColor.grayColor()

    }
}
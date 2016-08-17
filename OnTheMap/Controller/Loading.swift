//
//  Loading.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/17.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit

class Loading {
    
    static let loadingView: UIView = {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let loadingView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        loadingView.backgroundColor = UIColor.grayColor()
        loadingView.alpha = 0.5
        return loadingView
    }()
    
    static func startLoading() {
        UIApplication.sharedApplication().keyWindow?.addSubview(loadingView)
    }
    
    static func finishLoading() {
        loadingView.removeFromSuperview()
    }
    
}

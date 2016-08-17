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
        
//        let groupAnimation = CAAnimationGroup()
//        groupAnimation.animations = [Loading.alphaAnimation()]
//        groupAnimation.duration = 0.2
//        groupAnimation.autoreverses = true
//        groupAnimation.repeatDuration = 0.1
//        loadingView.layer.addAnimation(groupAnimation, forKey: "alphaAnimation")
        
        return loadingView
    }()
    
    static func startLoading() {
        UIApplication.sharedApplication().keyWindow?.addSubview(loadingView)
    }
    
    static func finishLoading() {
        loadingView.removeFromSuperview()
    }
    
    static func alphaAnimation() -> CABasicAnimation{
        let alphaAnim = CABasicAnimation(keyPath: "opacity")
        alphaAnim.fromValue = NSNumber(float: 1.0)
        alphaAnim.toValue = NSNumber(float: 0.0)
        return alphaAnim
    }
    
}

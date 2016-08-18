//
//  UdacityUserData.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/16.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import Foundation

struct UdacityUserData {
    let key: String?
    let firstName: String?
    let lastName: String?
    let location: String?
    let websiteURL: String?
    let linkedinURL: String?

    init(userData: [String:AnyObject?]) {
        self.key = userData[UdacityClient.ResponseKeys.UserDataKey] as? String
        self.firstName = userData[UdacityClient.ResponseKeys.UserDataFirstName] as? String
        self.lastName = userData[UdacityClient.ResponseKeys.UserDataLastName] as? String
        self.location = userData[UdacityClient.ResponseKeys.UserDataLocation] as? String
        self.websiteURL = userData[UdacityClient.ResponseKeys.UserDataWebsiteURL] as? String
        self.linkedinURL = userData[UdacityClient.ResponseKeys.UserDataLinkedinURL] as? String
    }
}

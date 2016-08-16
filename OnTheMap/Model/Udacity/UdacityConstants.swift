//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/15.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

extension UdacityClient {
    
    struct Constants {
        static let ApiKey: String = ""
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    struct Methods {
        static let Session = "/session"
    }
    
    struct ResponseKeys {
        static let Session = "session"
        static let SessionID = "id"
        static let Account = "account"
        static let AccountKey = "key"
        
        
        static let UserData = "user"
        static let UserDataKey = "key"
        static let UserDataFirstName = "first_name"
        static let UserDataLastName = "last_name"
        static let UserDataLocation = "location"
        static let UserDataWebsiteURL = "website_url"
        static let UserDataLinkedinURL = "linkedin_url"
    }
}
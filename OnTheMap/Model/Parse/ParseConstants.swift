//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/16.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import Foundation

extension ParseClient {
    
    struct Constants {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
    }
    
    struct Methods {
        static let StudentLocation = "/StudentLocation"
    }
    
    struct ResponseKeys {
        static let StudentLocationsResults = "results"
        
        static let StudentLocationObjectID = "objectId"
        static let StudentLocationUniqueKey = "uniqueKey"
        static let StudentLocationFirstName = "firstName"
        static let StudentLocationLastName = "lastName"
        static let StudentLocationLatitude = "latitude"
        static let StudentLocationLongitude = "longitude"
        static let StudentLocationMapString = "mapString"
        static let StudentLocationMediaURL = "mediaURL"
        static let StudentLocationUpdatedAt = "updatedAt"
        static let StudentLocationCreatedAt = "createdAt"
    }
}
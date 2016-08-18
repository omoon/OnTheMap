//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/15.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import Foundation

struct StudentInformation {

    var objectID: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    var updatedAt: String?
    var createdAt: String?

    init(info: [String:AnyObject?]) {
        self.objectID = info[ParseClient.ResponseKeys.StudentLocationObjectID] as? String
        self.uniqueKey = info[ParseClient.ResponseKeys.StudentLocationUniqueKey] as? String
        self.firstName = info[ParseClient.ResponseKeys.StudentLocationFirstName] as? String
        self.lastName = info[ParseClient.ResponseKeys.StudentLocationLastName] as? String
        self.latitude = info[ParseClient.ResponseKeys.StudentLocationLatitude] as? Double
        self.longitude = info[ParseClient.ResponseKeys.StudentLocationLongitude] as? Double
        self.mapString = info[ParseClient.ResponseKeys.StudentLocationMapString] as? String
        self.mediaURL = info[ParseClient.ResponseKeys.StudentLocationMediaURL] as? String
        self.updatedAt = info[ParseClient.ResponseKeys.StudentLocationUpdatedAt] as? String
        self.createdAt = info[ParseClient.ResponseKeys.StudentLocationCreatedAt] as? String
    }

    func name() -> String {
        if let firstName = self.firstName, let lastName = self.lastName {
            return "\(firstName) \(lastName)"
        }
        return "(No Name)"
    }

}
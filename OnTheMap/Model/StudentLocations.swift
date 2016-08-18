//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/15.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import Foundation

class StudentLocations {

    static let sharedInstance: StudentLocations = StudentLocations()

    var locations = [StudentInformation]()

    private init() {}

}
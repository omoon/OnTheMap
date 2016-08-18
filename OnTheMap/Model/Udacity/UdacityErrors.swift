//
// Created by omoon on 2016/08/18.
// Copyright (c) 2016 lamolabo. All rights reserved.
//

import Foundation

enum UdacityErrors: ErrorType {
    case NoUsername
    case NoPassword
    case InvalidUsername
    case InvalidPassword
    case InvalidStatusCode(response: NSURLResponse?)
    case CannotFetchSessionID
    case CannotFetchAccountKey
    case ResponseError(error: NSError?)
    case NoData(response: NSURLResponse?)
    case CannotParseJson(data: NSData)
    case CannotFetchUserData(result: AnyObject?)
}

//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/15.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import Foundation


// MARK: - TMDBClient: NSObject

class UdacityClient: NSObject {

    static let sharedInstance: UdacityClient = UdacityClient()

    // shared session
    var session = NSURLSession.sharedSession()

    var sessionID: String? = nil
    var myAccountKey: String? = nil
    var myUserData: UdacityUserData? = nil

    func logOut() {
        self.sessionID = nil
        self.myAccountKey = nil
    }

    func loginWithFaceBookLogin(accessToken: String, completionHandlerForAuth: (success:Bool, errorString:String?) -> Void) {
        let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}"
        doLogin(jsonBody, completionHandlerForAuth: completionHandlerForAuth)
    }

    func loginWithUsernameAndPassword(loginViewController: LoginViewController, completionHandlerForAuth: (success:Bool, errorString:String?) -> Void) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(loginViewController.textFieldUsername.text!)\", \"password\": \"\(loginViewController.textFieldPassword.text!)\"}}"
        doLogin(jsonBody, completionHandlerForAuth: completionHandlerForAuth)
    }

    private func doLogin(jsonBody: String, completionHandlerForAuth: (success:Bool, errorString:String?) -> Void) {

        let task = taskForPOSTMethod(Methods.Session, parameters: [:], jsonBody: jsonBody) {
            (results, error) in
            if error == nil {

                guard let fetchedSessionID = results[ResponseKeys.Session]!![ResponseKeys.SessionID] as? String else {
                    completionHandlerForAuth(success: false, errorString: "Can't fetch session dic.")
                    return
                }

                guard let fetchedAccountKey = results[ResponseKeys.Account]!![ResponseKeys.AccountKey] as? String else {
                    completionHandlerForAuth(success: false, errorString: "Can't fetch account key.")
                    return
                }

                self.sessionID = fetchedSessionID
                self.myAccountKey = fetchedAccountKey

                self.getUserData(self.myAccountKey!, completionHandlerForUserData: {
                    (success, userData, errorString) in
                    self.myUserData = UdacityUserData(userData: userData!)
                    ParseClient.sharedInstance.getStudentLocations(completionHandlerForAuth)
                })


            } else {
                completionHandlerForAuth(success: false, errorString: error?.localizedDescription)
            }
        }

        task.resume()

    }

    private func getUserData(account_key: String, completionHandlerForUserData: (success:Bool, userData:[String:AnyObject]?, errorString:String?) -> Void) {

        let task = taskForGETMethod("/users/\(account_key)", parameters: [:]) {
            (result, error) in
            if let error = error {
                completionHandlerForUserData(success: false, userData: nil, errorString: error.localizedDescription)
            } else {
                if let userData = result[ResponseKeys.UserData] as? [String:AnyObject] {
                    completionHandlerForUserData(success: true, userData: userData, errorString: nil)
                } else {
                    print("Could not find \(ResponseKeys.UserData) in \(result)")
                    completionHandlerForUserData(success: false, userData: nil, errorString: "can't fetch user data")
                }
            }

        }

        task.resume()

    }

    // MARK: GET

    func taskForGETMethod(method: String, parameters: [String:AnyObject], completionHandlerForGET: (result:AnyObject!, error:NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        var thisParameters = parameters

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(thisParameters, withPathExtension: method))

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in

            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print(response)
                sendError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (results:AnyObject!, error:NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in

            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(results: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result:AnyObject!, error:NSError?) -> Void) {

        var parsedResult: AnyObject!
        do {
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)

        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }

        completionHandlerForConvertData(result: parsedResult, error: nil)
    }

    // create a URL from parameters
    private func udacityURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {

        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()

        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.URL!
    }

    private func parseURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()

        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.URL!

    }

//    // MARK: Shared Instance
//    
//    class func sharedInstance() -> UdacityClient {
//        struct Singleton {
//            static var sharedInstance = UdacityClient()
//        }
//        return Singleton.sharedInstance
//    }
}
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

    func loginWithFaceBookLogin(accessToken: String, completionHandlerForAuth: (success:Bool, error:ErrorType?) -> Void) {
        let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}"
        doLogin(jsonBody, completionHandlerForAuth: completionHandlerForAuth)
    }

    func loginWithUsernameAndPassword(loginViewController: LoginViewController,
                                      completionHandlerForAuth: (success:Bool, error:ErrorType?) -> Void) {

        let username = loginViewController.textFieldUsername.text!
        let password = loginViewController.textFieldPassword.text!

        if username == "" {
            completionHandlerForAuth(success: false, error: UdacityErrors.NoUsername)
            return
        }

        if password == "" {
            completionHandlerForAuth(success: false, error: UdacityErrors.NoPassword)
            return
        }

        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        doLogin(jsonBody, completionHandlerForAuth: completionHandlerForAuth)
    }

    private func doLogin(jsonBody: String, completionHandlerForAuth: (success:Bool, error:ErrorType?) -> Void) {

        let task = taskForPOSTMethod(Methods.Session, parameters: [:], jsonBody: jsonBody) {
            (results, error) in
            if error == nil {

                guard let fetchedSessionID = results[ResponseKeys.Session]!![ResponseKeys.SessionID] as? String else {
                    completionHandlerForAuth(success: false, error: UdacityErrors.CannotFetchSessionID)
                    return
                }

                guard let fetchedAccountKey = results[ResponseKeys.Account]!![ResponseKeys.AccountKey] as? String else {
                    completionHandlerForAuth(success: false, error: UdacityErrors.CannotFetchAccountKey)
                    return
                }

                self.sessionID = fetchedSessionID
                self.myAccountKey = fetchedAccountKey

                self.getUserData(self.myAccountKey!, completionHandlerForUserData: {
                    (success, userData, error) in
                    if success {
                        self.myUserData = UdacityUserData(userData: userData!)
                        completionHandlerForAuth(success: true, error: nil)
                    } else {
                        completionHandlerForAuth(success: false, error: error)
                    }
                })

            } else {
                completionHandlerForAuth(success: false, error: error)
            }
        }

        task.resume()

    }

    private func getUserData(
            account_key: String,
            completionHandlerForUserData: (success:Bool, userData:[String:AnyObject]?, error:ErrorType?) -> Void) {

        let task = taskForGETMethod("/users/\(account_key)", parameters: [:]) {
            (result, error) in
            if let error = error {
                completionHandlerForUserData(success: false, userData: nil, error: error)
            } else {
                if let userData = result[ResponseKeys.UserData] as? [String:AnyObject] {
                    completionHandlerForUserData(success: true, userData: userData, error: nil)
                } else {
                    completionHandlerForUserData(
                            success: false,
                            userData: nil,
                            error: UdacityErrors.CannotFetchUserData(result: result)
                            )
                }
            }

        }

        task.resume()

    }

    // MARK: GET

    func taskForGETMethod(method: String,
                          parameters: [String:AnyObject],
                          completionHandlerForGET: (result:AnyObject!, error:ErrorType?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        var thisParameters = parameters

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(thisParameters, withPathExtension: method))

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in

            func sendError(error: ErrorType) {
                completionHandlerForGET(result: nil, error: error)
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(UdacityErrors.ResponseError(error: error))
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError(UdacityErrors.InvalidStatusCode(response: response))
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(UdacityErrors.NoData(response: response))
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    func taskForPOSTMethod(method: String,
                           parameters: [String:AnyObject],
                           jsonBody: String,
                           completionHandlerForPOST: (results:AnyObject!, error:ErrorType?) -> Void) -> NSURLSessionDataTask {

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

            func sendError(error: ErrorType) {
                completionHandlerForPOST(results: nil, error: error)
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(UdacityErrors.ResponseError(error: error))
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError(UdacityErrors.InvalidStatusCode(response: response))
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(UdacityErrors.NoData(response: response))
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
    private func convertDataWithCompletionHandler(
            data: NSData,
            completionHandlerForConvertData: (result:AnyObject!, error:ErrorType?) -> Void) {

        var parsedResult: AnyObject!
        do {
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)

        } catch {
            completionHandlerForConvertData(result: nil, error: UdacityErrors.CannotParseJson(data: data))
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

}
//
//  ParseClient.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/16.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import Foundation
import MapKit

class ParseClient: NSObject {

    static let sharedInstance: ParseClient = ParseClient()

    let udacityClient = UdacityClient.sharedInstance
    var studentLocations = StudentLocations.sharedInstance

    var myLocations = [StudentInformation]()

    // shared session
    var session = NSURLSession.sharedSession()

    func getStudentLocations(completionHandler: (success:Bool, error:ErrorType?) -> Void) {

        // clear
        studentLocations.locations = [StudentInformation]()
        myLocations = [StudentInformation]()

        let task = taskForGETMethod(Methods.StudentLocation, parameters: ["limit": 100, "order": "-updatedAt"]) {
            (result, error) in
            if error == nil {
                if let results = result[ResponseKeys.StudentLocationsResults] as? [[String:AnyObject]] {
                    for studentInfo in results {
                        let newStudentInfo = StudentInformation(info: studentInfo)
                        self.studentLocations.locations.append(newStudentInfo)

                        // skip invalid data
                        if newStudentInfo.uniqueKey == nil {
                            continue
                        }

                        // store my locations
                        if newStudentInfo.uniqueKey! == self.udacityClient.myAccountKey! {
                            self.myLocations.append(newStudentInfo)
                        }
                    }
                }
                completionHandler(success: true, error: nil)
            } else {
                print(error)
                completionHandler(success: false, error: ParseErrors.CannotFetchLocations)
            }
        }
        task.resume()
    }

    func postMyLocation(myUdacityUserData: UdacityUserData, mapItem: MKMapItem, urlString: String, completionHandler: (success:Bool, errorString:String?) -> Void) {

        let jsonBody = "{\"uniqueKey\": \"\(myUdacityUserData.key!)\", \"firstName\": \"\(myUdacityUserData.firstName!)\", \"lastName\": \"\(myUdacityUserData.lastName!)\",\"mapString\": \"\(mapItem.placemark.title!)\", \"mediaURL\": \"\(urlString)\", \"latitude\": \(mapItem.placemark.coordinate.latitude), \"longitude\": \(mapItem.placemark.coordinate.longitude)}"

        if myLocations.count == 0 {
            let task = taskForPOSTMethod("/StudentLocation", parameters: [:], jsonBody: jsonBody) {
                (results, error) in
                if let error = error {
                    completionHandler(success: false, errorString: error.localizedDescription)
                } else {
                    self.getStudentLocations({
                        (success, errorString) in
                        completionHandler(success: true, errorString: nil)
                    })
                }
            }
            task.resume()
        } else {
            print("/StudentLocation/\(myLocations[0].objectID!)")
            let task = taskForPUTMethod("/StudentLocation/\(myLocations[0].objectID!)", parameters: [:], jsonBody: jsonBody) {
                (results, error) in
                if let error = error {
                    completionHandler(success: false, errorString: error.localizedDescription)
                } else {
                    self.getStudentLocations({
                        (success, errorString) in
                        completionHandler(success: true, errorString: nil)
                    })
                }
            }
            task.resume()
        }

    }

    // MARK: GET

    func taskForGETMethod(method: String, parameters: [String:AnyObject], completionHandlerForGET: (result:AnyObject!, error:NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        var thisParameters = parameters

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(thisParameters, withPathExtension: method))

        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in

            func sendError(error: String) {
                print(error)
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

    func taskForPUTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPUT: (results:AnyObject!, error:NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "PUT"

        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in

            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPUT(results: nil, error: NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
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
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPUT)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (results:AnyObject!, error:NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"

        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
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
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)

        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }

        completionHandlerForConvertData(result: parsedResult, error: nil)
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
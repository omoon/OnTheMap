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
    
    static let sharedInstance = ParseClient()
    
    var studentLocations = [StudentInformation]()
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    func getStudentLocations(completionHander: (success: Bool, errorString: String?) -> Void) {
        let task = taskForGETMethod(Methods.StudentLocation, parameters: ["limit": 100]) { (result, error) in
            if error == nil {
                if let results = result[ResponseKeys.StudentLocationsResults] as? [[String: AnyObject]] {
                    for studentInfo in results {
                        self.studentLocations.append(StudentInformation(info: studentInfo))
                    }
                }
                completionHander(success: true, errorString: nil)
            } else {
                print(error)
            }
        }
        task.resume()
    }
    
    func postMyLocation(myUdacityUserData: UdacityUserData, mapItem: MKMapItem, urlString: String) {
        
       let jsonBody = "{\"uniqueKey\": \"\(myUdacityUserData.key!)\", \"firstName\": \"\(myUdacityUserData.firstName!)\", \"lastName\": \"\(myUdacityUserData.lastName!)\",\"mapString\": \"\(mapItem.placemark.title!)\", \"mediaURL\": \"\(urlString)\", \"latitude\": \(mapItem.placemark.coordinate.latitude), \"longitude\": \(mapItem.placemark.coordinate.longitude)}"
        
        print(jsonBody)
        
    }
    
    // MARK: GET
    
    func taskForGETMethod(method: String, parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var thisParameters = parameters
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(thisParameters, withPathExtension: method))
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
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
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    private func parseURLFromParameters(parameters: [String: AnyObject], withPathExtension: String? = nil) -> NSURL {
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
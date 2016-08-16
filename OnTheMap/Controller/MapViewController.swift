//
//  MapViewController.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/13.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, MapAndList {
    
    let parseClient = ParseClient.sharedInstance
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonEditInfo: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for studentInfo in parseClient.studentLocations {
            
            if let latitude = studentInfo.latitude, let longitude = studentInfo.longitude {
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = studentInfo.name()
                annotation.subtitle = studentInfo.mediaURL
                mapView.addAnnotation(annotation)
            }
            
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let urlString = view.annotation?.subtitle {
            openURL(urlString!)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let informationPostingViewController = segue.destinationViewController as! InformationPostingViewController
        informationPostingViewController.test = 2
    }
    
    @IBAction func editInfo(sender: AnyObject) {
        self.showInformationPostingView()
    }
    
    @IBAction func logOut(sender: AnyObject) {
        self.doLogOut()
    }
    
}

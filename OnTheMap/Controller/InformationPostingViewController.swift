//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/14.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    var test: Int = 0
    var mapItem: MKMapItem? = nil

    let udacityClient = UdacityClient.sharedInstance
    let parseClient = ParseClient.sharedInstance

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        displaySearchLocationView()
        locationTextField.delegate = self
        urlTextField.delegate = self
    }

    private func displaySearchLocationView() {

        var message = ""
        if let firstName = udacityClient.myUserData?.firstName {
            message = "Hi, \(firstName)!"
        }

        nameLabel.text = "\(message)\nWhere are you studying today?"
        locationTextField.hidden = false
        searchLocationButton.hidden = false
        urlTextField.hidden = true
        mapView.hidden = true
        submitButton.enabled = false

    }

    private func displayURLInputView() {
        nameLabel.text = "Enter your link!"
        locationTextField.hidden = true
        searchLocationButton.hidden = true
        urlTextField.hidden = false
        mapView.hidden = false
        mapView.selectAnnotation(mapView.annotations[0], animated: true)
        submitButton.enabled = true
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func pressSearchLocation(sender: AnyObject) {

        view.endEditing(true)
        Loading.startLoading()

        self.mapView.removeAnnotations(self.mapView.annotations)

        guard let locationString = locationTextField.text else {
            print("no location string")
            return
        }

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = locationString
        request.region = mapView.region

        let search = MKLocalSearch(request: request)

        search.startWithCompletionHandler {
            (response, error) in
            if let error = error {
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                performUIUpdatesOnMain({
                    self.showAlert(self, title: "Location Not Found", message: "Try again, please😊")
                })
            } else {
                for item in response!.mapItems {

                    // Display the received items
                    self.mapItem = item
                    let coordinate = item.placemark.coordinate
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = item.placemark.title!
                    self.mapView.addAnnotation(annotation)
                    self.mapView.setCenterCoordinate(annotation.coordinate, animated: true)
                    self.mapView.camera.altitude = 10000.0

                    break
                }
                performUIUpdatesOnMain({
                    self.displayURLInputView()
                })
            }

            Loading.finishLoading()

        }
    }

    @IBAction func pressSubmit(sender: AnyObject) {
        Loading.startLoading()
        parseClient.postMyLocation(udacityClient.myUserData!, mapItem: mapItem!, urlString: urlTextField.text!) {
            (success, errorString) in
            Loading.finishLoading()
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                performUIUpdatesOnMain({
                    self.showAlert(self, title: "Error", message: "Could not submit your location.\nTry again, please😊")
                })
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}

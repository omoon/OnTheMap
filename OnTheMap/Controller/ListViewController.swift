//
//  ListViewController.swift
//  OnTheMap
//
//  Created by omoon on 2016/08/13.
//  Copyright © 2016年 lamolabo. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, MapAndList {

    var selectedRow: Int!

    let studentLocations = StudentLocations.sharedInstance

    @IBOutlet weak var buttonEditInfo: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStudentLocatons()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    func refreshStudentLocatons() {
        Loading.startLoading()
        reloadStudentLocations {
            (success, errorString) in
            performUIUpdatesOnMain({
                if success {
                    self.tableView.reloadData()
                } else {
                    performUIUpdatesOnMain({
                        self.presentViewController(self.createAlert("Error", message: "Could not fetch locations."), animated: true, completion: nil)
                    })
                }
                Loading.finishLoading()
            })
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.locations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listTableViewCell", forIndexPath: indexPath) as UITableViewCell!
        cell.textLabel!.text = studentLocations.locations[indexPath.row].name()
        cell.detailTextLabel?.text = studentLocations.locations[indexPath.row].mapString
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        openURL(studentLocations.locations[indexPath.row].mediaURL!)
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

    @IBAction func pressRefresh(sender: AnyObject) {
        refreshStudentLocatons()
    }
}

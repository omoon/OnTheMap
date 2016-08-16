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
    
    let parseClient = ParseClient.sharedInstance
    
    @IBOutlet weak var buttonEditInfo: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseClient.studentLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listTableViewCell", forIndexPath: indexPath) as UITableViewCell!
        cell.textLabel!.text = parseClient.studentLocations[indexPath.row].name()
        cell.detailTextLabel?.text = parseClient.studentLocations[indexPath.row].mediaURL
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        openURL(parseClient.studentLocations[indexPath.row].mediaURL!)
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
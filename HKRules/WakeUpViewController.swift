//
//  WakeUpViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 7/30/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse
import MediaPlayer

class WakeUpViewController: UIViewController, MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setAlarm(sender: UIButton) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        let dateString = dateFormatter.stringFromDate(datePicker.date)
        println(dateString)
        let u = PFUser.currentUser()?.username
        PFCloud.callFunctionInBackground("setCloudAlarm", withParameters: ["alarmTime": dateString, "username":u!]) { (response: AnyObject?, error: NSError?) -> Void in
            let test = response as? String
            println(test)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var optionalCell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell?
        if optionalCell == nil {
            optionalCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }
        var cell = optionalCell!
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Standard Alarm"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        case 1:
            cell.textLabel?.text = "Song"
            if selectedSong != nil && tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType != UITableViewCellAccessoryType.Checkmark {
                cell.detailTextLabel?.text = selectedSong?.title
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        case 2:
            cell.textLabel?.text = "Standard Alarm"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        default:
            cell.textLabel?.text = "Standard Alarm"
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

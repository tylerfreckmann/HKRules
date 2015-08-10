//
//  ShowerViewController.swift
//  HKRules
//
//  Created by Eric Tan on 8/7/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse

class ShowerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var savedBtn: UIButton!
    
    var user: PFUser!
    var currentShower: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set date picker to only pick time 
        datePicker.datePickerMode = UIDatePickerMode.CountDownTimer
        
        // Set initial time countdown to 5 minutes. (stock value) 
        datePicker.countDownDuration = 300
        
        // Initialize User
        user = PFUser.currentUser()!
        
        // Initialize showerConfig
        var optionalShowerConfig: AnyObject? = user["showerConfig"]
        if optionalShowerConfig == nil {
            currentShower = PFObject(className: "ShowerConfig")
            currentShower["timeTillAlert"] = 300
            currentShower.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.user["showerConfig"] = self.currentShower
                    self.user.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if !success {
                            println("IN shower FUNCTION viewDidLoad - user.save" + error!.localizedDescription)
                        }
                    })
                } else {
                    println("IN shower FUNCTION viewDidLoad - showerConfig.save" + error!.localizedDescription)
                }
            })
        } else {
            currentShower = optionalShowerConfig as! PFObject
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func savedPressed(sender: UIButton) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var showerDuration = dateFormatter.stringFromDate(datePicker.date)
        var hoursAndMinutes = showerDuration.componentsSeparatedByString(":")
        var hours = hoursAndMinutes[0]
        var minutes = hoursAndMinutes[1]
        var totalSecs = convertToSecs(hours.toInt()!, minutes: minutes.toInt()!)
        println("Total seconds: \(totalSecs)")
        
        // save shower time to the parse cloud 
        currentShower["timeTillAlert"] = totalSecs
        currentShower.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.user["showerConfig"] = self.currentShower
                self.user.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if !success {
                        println("IN shower FUNCTION savePressed- user.save" + error!.localizedDescription)
                    }
                })
            } else {
                println("IN shower FUNCTION savePressed- showerConfig.save" + error!.localizedDescription)
            }
        })
        
    }

    func convertToSecs(hours: Int, minutes: Int) -> Int {
        var hoursToSec = hours * 3600
        var minutesToSec = minutes * 60
        return hoursToSec + minutesToSec
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

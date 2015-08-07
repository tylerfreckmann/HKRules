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
    var showerConfig: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set date picker to only pick time 
        datePicker.datePickerMode = UIDatePickerMode.CountDownTimer
        
        // Initialize User
        user = PFUser.currentUser()!
        
        // Initialize showerConfig
        var optionalShowerConfig: AnyObject? = user["showerConfig"]
        if optionalShowerConfig == nil {
            showerConfig = PFObject(className: "showerConfig")
            showerConfig["timeTillAlert"] = 120
            showerConfig.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.user["showerConfig"] = self.showerConfig
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
            showerConfig = optionalShowerConfig as! PFObject
            showerConfig.fetch()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func savedPressed(sender: UIButton) {
        
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

//
//  ViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 7/29/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse

class LogInSignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            self.performSegueWithIdentifier("skipToChooseScenario", sender: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // Initialize HKWControlHandler
        var g_alert: UIAlertController!
        
        if !HKWControlHandler.sharedInstance().isInitialized() {
            // show the network initialization dialog
            g_alert = UIAlertController(title: "Initializing", message: "If this dialog does not disappear, please check if any other HK WirelessHD App is running on the phone and kill it. Or, your phone is not in a Wifi network.", preferredStyle: .Alert)
            
            self.presentViewController(g_alert, animated: true, completion: nil)
        }
        
        if !HKWControlHandler.sharedInstance().initializing() && !HKWControlHandler.sharedInstance().isInitialized() {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if HKWControlHandler.sharedInstance().initializeHKWirelessController(kLicenseKeyGlobal, withSpeakersAdded:true) != 0 {
                    println("initializeHKWirelessControl failed : invalid license key")
                    return
                }
                println("initializeHKWirelessControl - OK");
                
                // dismiss the network initialization dialog
                if g_alert != nil {
                    g_alert.dismissViewControllerAnimated(true, completion: nil)
                }
                
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

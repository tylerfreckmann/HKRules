//
//  LogInVCViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 7/30/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logIn(sender: UIButton) {
        PFUser.logInWithUsernameInBackground(usernameField.text, password: passwordField.text) { (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                let installation = PFInstallation.currentInstallation()
                installation["user"] = user
                installation.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
                })
            } else {
                let errorString = error!.userInfo?["error"] as? String
                let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
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

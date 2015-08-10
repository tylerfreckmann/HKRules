//
//  ParseLoginVC.swift
//  HKRules
//
//  Created by Eric Tan on 8/10/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class ParseLoginVC: UIViewController, PFLogInViewControllerDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() != nil) {
            self.performSegueWithIdentifier("goToScenarios", sender: self)
        }
        else {
            var logInViewController = PFLogInViewController()
            logInViewController.fields = (PFLogInFields.UsernameAndPassword
                | PFLogInFields.LogInButton
                | PFLogInFields.SignUpButton
                | PFLogInFields.PasswordForgotten)
            logInViewController.delegate = self
            self.presentViewController(logInViewController, animated: false, completion: nil)
        }
    }
    
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
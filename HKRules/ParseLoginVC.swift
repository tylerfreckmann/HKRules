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

class ParseLoginVC: PFLogInViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkGrayColor()
        /*println("Got here")
        let picturePath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Harman_Logo.png")
        var logoImage = UIImage(named: "Harman_Logo.png", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)
        let logoView = UIImageView(image: logoImage)
        self.logInView!.logo = logoView*/
    }
    
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() != nil) {
            self.performSegueWithIdentifier("goToScenarios", sender: self)
        }
        else {
            let logInViewController = PFLogInViewController()
            logInViewController.fields = (PFLogInFields.UsernameAndPassword
                | PFLogInFields.LogInButton
                | PFLogInFields.SignUpButton
                | PFLogInFields.PasswordForgotten)
            logInViewController.delegate = self
            self.presentViewController(logInViewController, animated: false, completion: nil)
            
            let signInViewController = PFSignUpViewController()
            signInViewController.delegate = self
            logInViewController.signUpController = signInViewController
        }
    }
    
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
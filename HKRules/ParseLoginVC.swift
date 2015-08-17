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
    
    let logInViewController = PFLogInViewController()
    let signInViewController = PFSignUpViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkGrayColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() != nil) {
            self.performSegueWithIdentifier("goToScenarios", sender: self)
        }
        else {
            // Set log in traits
            logInViewController.fields = (PFLogInFields.UsernameAndPassword
                | PFLogInFields.LogInButton
                | PFLogInFields.SignUpButton
                | PFLogInFields.PasswordForgotten)
            logInViewController.delegate = self
            self.presentViewController(logInViewController, animated: false, completion: nil)
            
            // Set sign up traits
            signInViewController.fields = (PFSignUpFields.UsernameAndPassword
                | PFSignUpFields.SignUpButton
                | PFSignUpFields.Email
                | PFSignUpFields.Additional
                | PFSignUpFields.DismissButton)
            signInViewController.signUpView?.additionalField?.placeholder = "Name"
            signInViewController.delegate = self
            logInViewController.signUpController = signInViewController
        }
    }
    
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        updateInstallation()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) -> Void {
        updateInstallation()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateInstallation() {
        let installation = PFInstallation.currentInstallation();
        installation["user"] = PFUser.currentUser();
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                println(error)
            }
        }
    }
}
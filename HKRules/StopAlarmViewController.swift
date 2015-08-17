//
//  StopAlarmViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 8/12/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class StopAlarmViewController: UIViewController, CLLocationManagerDelegate{
    
    var wakeConfig: PFObject!
    var greetingURL: String!
    var weather: Bool!
    var lights: Bool!
    var appDelegate: AppDelegate!
    
    let locationManager = CLLocationManager()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("called viewDidLoad")
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var user = PFUser.currentUser()!
        var optionalWakeConfig: AnyObject? = user["wakeConfig"]
        wakeConfig = optionalWakeConfig as! PFObject
        HKWPlayerEventHandlerSingleton.sharedInstance().delegate = appDelegate
        wakeConfig.fetch()
        populateData()
    
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateData() {
        println("called populateData")
        greetingURL = wakeConfig["greetingURL"] as! String
        weather = wakeConfig["weather"] as! Bool
        lights = wakeConfig["lights"] as! Bool
    }
    

    @IBAction func stopPressed(sender: UIButton) {
        HKWControlHandler.sharedInstance().stop()
        appDelegate.appendToQueue(greetingURL)
        appDelegate.playFromQueue()
        if weather==true {
            println("weather is true")
            var currentLocation = CLLocation()
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
                    currentLocation = locationManager.location
            }
            
            var geoPoint = currentLocation.coordinate
            PFCloud.callFunctionInBackground("getWeather", withParameters: ["latitude": geoPoint.latitude, "longitude": geoPoint.longitude], block: { (response, error) -> Void in
                var weatherURL = response as! String
                self.appDelegate.appendToQueue(weatherURL)
            })
        }
        if lights == true {
            PFCloud.callFunctionInBackground("turnOnLights", withParameters: nil, block: { (response, error) -> Void in
                
            })
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

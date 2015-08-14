//
//  StopAlarmViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 8/12/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse

class StopAlarmViewController: UIViewController {
    
    var wakeConfig: PFObject!
    var greetingURL: String!
    var weather: Bool!
    var lights: Bool!
    var tracksQueue: [String]!
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("called viewDidLoad")
        tracksQueue = [String]()
        var user = PFUser.currentUser()!
        var optionalWakeConfig: AnyObject? = user["wakeConfig"]
        wakeConfig = optionalWakeConfig as! PFObject
        wakeConfig.fetchInBackgroundWithTarget(self, selector: "populateData")
        // Do any additional setup after loading the view.
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
        tracksQueue.append(greetingURL)
        if weather==true {
            PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint, error) -> Void in
                if error == nil {
                    PFCloud.callFunctionInBackground("getWeather", withParameters: ["latitude": geoPoint!.latitude, "longitude": geoPoint!.longitude], block: { (response, error) -> Void in
                        println("response: \(response) error: \(error)")
                    })
                } else {
                    println("error getting location")
                }
            })
        }
    }
    

    @IBAction func stopPressed(sender: UIButton) {
        HKWControlHandler.sharedInstance().stop()
    }
    
    func playFromQueue() {
        if !HKWControlHandler.sharedInstance().isPlaying() {
            let track = tracksQueue.removeAtIndex(0)
            if track.hasPrefix("http") {
                HKWControlHandler.sharedInstance().playStreamingMedia(track, withCallback: { (success) -> Void in
                    println("PLAY FROM QUEUE \(track)? \(success)")
                })
            } else {
                HKWControlHandler.sharedInstance().playCAF(NSURL(fileURLWithPath: track), songName: "", resumeFlag: false)
            }
        }
    }
    
    func hkwPlayEnded() {
        println("playing next song, track count: \(tracksQueue.count)")
        if tracksQueue.count != 0 {
            playFromQueue()
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

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

class WakeUpViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    var mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.Music)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.showsCloudItems = false
        mediaPicker.prompt = "Choose Alarm Song"
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
    
    @IBAction func chooseAlarmSound(sender: UIButton) {
        self.presentViewController(mediaPicker, animated: true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        // UPDATE PLAYER QUEUE
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

//
//  StopAlarmViewController.swift
//  HKRules
//
//  Created by Tyler Freckmann on 8/12/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit

class StopAlarmViewController: UIViewController {

    var alarm: [NSObject : AnyObject]?
    
    convenience init() {
        self.init(alarm: nil)
    }
    
    init(alarm: [NSObject : AnyObject]?) {
        self.alarm = alarm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

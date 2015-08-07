//
//  AppDelegate.swift
//  HKRules
//
//  Created by Tyler Freckmann on 7/29/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sleepPreventer : MMPDeepSleepPreventer!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("q0zDsAFXiBtK2FFHMwBnsqWvqsNBZcJJy3GFL9xa",
            clientKey: "YCaxY5KPgHdrGLZoUUwReGIyqEyAtAVFc0r0Mkb3")
        
        // Register for Push Notitications
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        
        // Extract the notification data
        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            
            // Create a pointer to the Photo object
            let showerAlertURL = notificationPayload["ttsURL"] as? NSString
            /*let targetPhoto = PFObject(withoutDataWithClassName: "Photo", objectId: "xWMyZ4YEGZ")
            
            // Fetch photo object
            targetPhoto.fetchIfNeededInBackgroundWithBlock {
                (object: PFObject?, error:NSError?) -> Void in
                if error == nil {
                    // Show photo view controller
                    println("Got in here after recieiving push!")
                }
            }*/
        }
        
        // prevent from turning into background
        sleepPreventer = MMPDeepSleepPreventer()
        sleepPreventer.startPreventSleep()
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if !success {
                println("IN AppDelegate FUNCTION application: didRegisterForRemoteNotificationsWithDeviceToken" + error!.localizedDescription)
            }
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        println("notification")
        if let soundAlarm: AnyObject = userInfo["soundAlarm"] {
            let nsWavPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("alarm.wav")
            let url = NSURL(fileURLWithPath: nsWavPath)
            println(HKWControlHandler.sharedInstance().playWAV(nsWavPath))
            println(nsWavPath)
            var timer = NSTimer(timeInterval: 10, target: self, selector: "stop", userInfo: nil, repeats: false)
        }
        
        if let alertURL: AnyObject = userInfo["ttsURL"] {
            // play tts throgugh playStreamng 
            HKWControlHandler.sharedInstance().playStreamingMedia(alertURL as! String, withCallback: { bool in
                println(bool)
                println(alertURL)
                println("Can play!")
            } )
        }
        
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func stop() {
        println("stopped")
        HKWControlHandler.sharedInstance().stop()
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        PFPush.handlePush(userInfo)
//    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


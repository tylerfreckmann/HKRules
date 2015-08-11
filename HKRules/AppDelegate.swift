//
//  AppDelegate.swift
//  HKRules
//
//  Created by Tyler Freckmann, Eric Tran on 7/29/15.
//  Copyright (c) 2015 Tyler Freckmann. All rights reserved.
//

import UIKit
import Parse
import MediaPlayer

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
        
        // Configure Push notification types
        // Action
        var stopAlarmSoundAction = UIMutableUserNotificationAction()
        stopAlarmSoundAction.identifier = "STOP_ALARM_SOUND"
        stopAlarmSoundAction.title = "Good Morning!"
        stopAlarmSoundAction.activationMode = UIUserNotificationActivationMode.Foreground
        stopAlarmSoundAction.destructive = false
        // Category
        var stopAlarmSoundCategory = UIMutableUserNotificationCategory()
        stopAlarmSoundCategory.identifier = "STOP_ALARM_SOUND_CATEGORY"
        stopAlarmSoundCategory.setActions([stopAlarmSoundAction], forContext: UIUserNotificationActionContext.Minimal)
        
        
        // Register for Push Notitications
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: Set(arrayLiteral: [stopAlarmSoundCategory]))
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            println("did register for remote notifications")
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
        println("Push notification received.")
        if let soundAlarm: AnyObject = userInfo["soundAlarm"] {
            println(userInfo)
            
            if !HKWControlHandler.sharedInstance().isPlaying() {
                // Play sound
                let soundFile = userInfo["soundFile"] as! String
                if soundFile == "alarm" {
                    let nsWavPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("alarm.wav")
                    let url = NSURL(fileURLWithPath: nsWavPath)
                    println(HKWControlHandler.sharedInstance().playWAV(nsWavPath))
                    println(nsWavPath)
                    var timer = NSTimer(timeInterval: 10, target: self, selector: "stop", userInfo: nil, repeats: false)
                } else {
                    let query = MPMediaQuery.songsQuery()
                    let predicate = MPMediaPropertyPredicate(value: soundFile, forProperty: MPMediaItemPropertyPersistentID)
                    query.addFilterPredicate(predicate)
                    
                    let item = query.items.first as! MPMediaItem
                    var assetURL = item.assetURL
                    println(HKWControlHandler.sharedInstance().playCAF(assetURL, songName: item.title, resumeFlag: false))
                }
            }
        }
        
        if let alertURL: AnyObject = userInfo["ttsURL"] {
            // Play TTS shower alert through playStreamng
            HKWControlHandler.sharedInstance().playStreamingMedia(alertURL as! String, withCallback: { bool in
                println(alertURL)
                println("Playing shower TTS...")
            } )
        }
        
        if let leaveFlag: AnyObject = userInfo["leaveFlag"] {
            // Received a notification from prepareToLeaveHouse event triggered in cloud
            
            // Play initial check TTS through playStreaming
            let initialCheckURL: AnyObject = userInfo["initialCheckURL"]!
            HKWControlHandler.sharedInstance().playStreamingMedia(initialCheckURL as! String, withCallback: { bool in
                println("Playing initial leave house check TTS...")
            } )
            
        }
        
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        println("handling action")
        println(identifier)
        println(userInfo)
        HKWControlHandler.sharedInstance().stop()
        completionHandler()
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


//
//  AppDelegate.swift
//  GradebookExample
//
//  Created by John Bellardo on 2/13/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let loader = GradebookURLLoader()
        
        // Live data URL
        // loader.baseURL = "https://users.csc.calpoly.edu/~bellardo/cgi-bin/grades.json"
        
        // Test data URL
        loader.baseURL = "https://users.csc.calpoly.edu/~bellardo/cgi-bin/test/grades.json"
        if loader.loginWithUsername("test", andPassword: "kj34mns04d") {
            println("Auth worked!")
            let data = loader.loadDataFromPath("?record=sections", error: nil)
            
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
       
            //println("Data: \(str)")
            let json = JSON(data: data)
            for (index, section) in json["sections"] {
                println(section["id"].stringValue)
            }
            if let tabVC = window?.rootViewController as? UINavigationController {
                for controller in tabVC.viewControllers {
                    if let tableView = controller as? SectionsTableViewController {
                        tableView.json = json
                        tableView.loader = loader
                    }
                }
            }
        }
        else {
            println("Auth failed!")
        }
        
        return true
    }

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


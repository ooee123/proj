//
//  LoginViewController.swift
//  GradebookExample
//
//  Created by Classroom Tech User on 3/8/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var JSONurl: UITextField!
    let loader = GradebookURLLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
/*
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "LoginSegue" {
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let destNav = splitViewController?.viewControllers[0] as UINavigationController
                let dest = destNav.viewControllers.first as SectionsTableViewController
                
                // Live data URL
                
                loader.baseURL = JSONurl.text
                if loader.loginWithUsername(username.text, andPassword: password.text) {
                    let data = loader.loadDataFromPath("?record=sections", error: nil)
                    let json = JSON(data: data)
                    
                    dest.loader = loader
                    dest.json = json

                }
                else
                {
                    println(username.text)
                    println(password.text)
                    println(JSONurl.text)
                    println("Cannot authenticate")
                }
                let detail = splitViewController?.viewControllers.last as UIViewController
                detail.performSegueWithIdentifier("iPadDetail", sender: self)
            }

        }
        return true
    }
*/    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "LoginSegue" {
            let dest = segue.destinationViewController as SectionsTableViewController
            
            // Live data URL
            loader.baseURL = JSONurl.text
            if loader.loginWithUsername(username.text, andPassword: password.text) {
                let data = loader.loadDataFromPath("?record=sections", error: nil)
                let json = JSON(data: data)
                dest.loader = loader
                dest.json = json
            }
            else
            {
                println(username.text)
                println(password.text)
                println(JSONurl.text)
                println("Cannot authenticate")
            }
        }
    }


}

//
//  EnrollmentCollectionViewController.swift
//  GradebookExample
//
//  Created by Classroom Tech User on 3/8/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit



class EnrollmentCollectionViewController: UITableViewController {

    var enrollmentsJSON : JSON = nil
    var term : Int = 0
    var course : Int = 0
    var loader : GradebookURLLoader = GradebookURLLoader()
    let reuseIdentifier = "EnrollmentCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return enrollmentsJSON["enrollments"].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as EnrollmentViewCellTableViewCell
        // Configure the cell...
        cell.enrollment = enrollmentsJSON["enrollments"][indexPath.row]
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    /*
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "EnrollmentDetailSegue") {
            let cell = sender as EnrollmentViewCellTableViewCell
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let destNav = splitViewController?.viewControllers.last as UINavigationController //AssignmentTableViewController
                let dest = destNav.viewControllers.first as AssignmentTableViewController
                let user = cell.enrollment["csc_username"].stringValue
                let data = loader.loadDataFromPath("?record=userscores&term=\(term)&course=\(course)&user=\(user)", error: nil)
                
                let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                println(str)
                dest.userscoresJSON = JSON(data: data)
                dest.term = term
                dest.course = course
                dest.loader = loader
                return false
            }
            return true
        }
        return false
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        if segue.identifier == "EnrollmentDetailSegue" {
            let cell = sender as EnrollmentViewCellTableViewCell
            let dest = segue.destinationViewController as AssignmentTableViewController
            let user = cell.enrollment["csc_username"].stringValue

            
            let data = loader.loadDataFromPath("?record=userscores&term=\(term)&course=\(course)&user=\(user)", error: nil)
            
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(str)
            dest.userscoresJSON = JSON(data: data)
            dest.term = term
            dest.course = course
            dest.loader = loader
        }
        // Pass the selected object to the new view controller.
    }
    
}

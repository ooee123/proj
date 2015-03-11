//
//  AssignmentTableViewController.swift
//  GradebookExample
//
//  Created by Classroom Tech User on 3/8/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit

class AssignmentTableViewController: UITableViewController {

    let reuseIdentifier = "AssignmentCell"
    var loader : GradebookURLLoader = GradebookURLLoader()
    var userscoresJSON : JSON = nil
    var term : Int = 0
    var course : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return userscoresJSON["userscores"].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as AssignmentTableViewCell

        // Configure the cell...
        cell.userscoreJSON = userscoresJSON["userscores"][indexPath.row]
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

    
    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "ScoresDetailSegue") {
            let sender = sender as AssignmentTableViewCell
        
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let dest = splitViewController?.viewControllers[1] as ScoresTableViewController
                let asnid = sender.userscoreJSON["id"].intValue
                var path = "?record=asnstats&term=\(term)&course=\(course)&id=\(asnid)"
                let data = loader.loadDataFromPath(path, error: nil)
                dest.yourScore = sender.yourScore
                dest.name = sender.name
                dest.statsJSON = JSON(data: data)
                return false
            }
            return true
        }
        return false
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        if segue.identifier == "ScoresDetailSegue" {
            let sender = sender as AssignmentTableViewCell
            let dest = segue.destinationViewController as ScoresTableViewController
            let asnid = sender.userscoreJSON["id"].intValue
            var path = "?record=asnstats&term=\(term)&course=\(course)&id=\(asnid)"

            let data = loader.loadDataFromPath(path, error: nil)
            dest.yourScore = sender.yourScore
            dest.name = sender.name            
            dest.statsJSON = JSON(data: data)
        }
        
        // Pass the selected object to the new view controller.
    }
    

}

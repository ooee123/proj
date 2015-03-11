//
//  ScoresTableViewController.swift
//  GradebookExample
//
//  Created by Classroom Tech User on 3/8/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit

class ScoresTableViewController: UITableViewController {

    var statsJSON : JSON = nil {
        didSet {
            let asnstats = statsJSON["asnstats"]
            possible = asnstats["points"].intValue
            min = asnstats["min_score"].intValue
            max = asnstats["max_score"].intValue
            mean = asnstats["mean_score"].doubleValue
            median = asnstats["median_score"].doubleValue
            stdDev = asnstats["std_dev"].doubleValue
            attempts = asnstats["attempts"].intValue
            self.tableView?.reloadData()
        }
    }
    var yourScore : Int = 0
    var possible : Int = 0
    var min : Int = 0
    var max : Int = 0
    var mean : Double = 0.0
    var median : Double = 0.0
    var stdDev : Double = 0.0
    var attempts : Int = 0
    
    var name : String = ""
    let reuseIdentifier = "ScoreCell"
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if statsJSON == nil {
            return 0
        }
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 7
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as ScoreTableViewCell

        // Configure the cell...
        if indexPath.section == 0 {
            cell.labelText = "Your score: \(yourScore) / \(possible)"
        }
        else if indexPath.section == 1 {
            switch (indexPath.row + 1) {
            case 1:
                cell.labelText = "Total Possible Points: \(possible)"
            case 2:
                cell.labelText = "Mean Score \(mean)"
            case 3:
                cell.labelText = "Min Score \(min)"
            case 4:
                cell.labelText = "Max Score \(max)"
            case 5:
                cell.labelText = "Median Score \(median)"
            case 6:
                cell.labelText = "Standard Deviation \(stdDev)"
            case 7:
                cell.labelText = "Attempts \(attempts)"
            default:
                cell.labelText = "OUT OF BOUNDS"
            }
        }
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

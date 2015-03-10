//
//  AssignmentTableViewCell.swift
//  GradebookExample
//
//  Created by Classroom Tech User on 3/8/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit

class AssignmentTableViewCell: UITableViewCell {

    @IBOutlet weak var assignmentLabel: UILabel!
    var yourScore : Int = 0
    var possible : Int = 0
    var name : String = ""
    var userscoreJSON : JSON = nil {
        didSet {
            name = userscoreJSON["name"].stringValue
            possible = userscoreJSON["max_points"].intValue
            var scoresJSON = userscoreJSON["scores"].dictionary
            yourScore = userscoreJSON["scores"][0]["score"].intValue
            println(scoresJSON)
            assignmentLabel.text = "\(name) \(yourScore) / \(possible)"
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

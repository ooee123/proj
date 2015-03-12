//
//  AllScoresTableViewCell.swift
//  GradebookExample
//
//  Created by Classroom Tech User on 3/10/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit

class AllScoresTableViewCell: UITableViewCell {
    @IBOutlet weak var scoresLabel: UILabel!

    var counts : Bool = false
    var score : Int = 0 {
        didSet {
            var text : String = ""
            if counts {
                text = "Counting score: \(score)"
            }
            else {
                text = "Attempt: \(score)"
            }
            scoresLabel.text = text
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

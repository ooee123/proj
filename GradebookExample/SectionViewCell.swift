//
//  SectionViewCell.swift
//  GradebookExample
//
//  Created by Classroom Tech User on 3/5/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit

class SectionViewCell: UITableViewCell {
    @IBOutlet weak var sectionLabel: UILabel!

    var dept : String = ""
    var course : Int = 0
    var title : String = ""
    var term : Int = 0
    
    var sectionJSON : JSON = nil {
        didSet {
            dept = sectionJSON["dept"].stringValue
            course = sectionJSON["course"].intValue
            title = sectionJSON["title"].stringValue
            term = sectionJSON["term"].intValue
            sectionLabel?.text = "\(dept) \(course) \(title)"
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

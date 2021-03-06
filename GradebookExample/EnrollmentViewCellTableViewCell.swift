//
//  EnrollmentViewCellTableViewCell.swift
//  GradebookExample
//
//  Created by Classroom Tech User on 3/8/15.
//  Copyright (c) 2015 John Bellardo. All rights reserved.
//

import UIKit

class EnrollmentViewCellTableViewCell: UITableViewCell {
    @IBOutlet weak var enrollmentsLabel: UILabel!

    var enrollment : JSON = nil {
        didSet {
            let first = enrollment["first_name"].stringValue
            let last = enrollment["last_name"].stringValue
            enrollmentsLabel.text = "\(first) \(last)"
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

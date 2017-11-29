//
//  gradeTableViewCell.swift
//  ProfileSetting
//
//  Created by Yi Jerry on 2017-09-23.
//  Copyright © 2017 Yi Jerry. All rights reserved.
//

import UIKit

class gradeTableViewCell: UITableViewCell {

    // MARK: - When Cell Loads
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var gradeCellLabel: UILabel!
    
    @IBOutlet weak var userGraderLabel: UILabel!
    
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state
    //    }
    
}

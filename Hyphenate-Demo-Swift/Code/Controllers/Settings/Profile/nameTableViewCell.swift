//
//  nameTableViewCell.swift
//  ProfileSetting
//
//  Created by Yi Jerry on 2017-09-23.
//  Copyright © 2017 Yi Jerry. All rights reserved.
//

import UIKit

class nameTableViewCell: UITableViewCell {

    // MARK: - When Cell Loads
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Outlets
    
    
    
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state
    //    }
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var nameCellLabel: UILabel!
}

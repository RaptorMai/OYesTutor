//
//  profilePictureTableViewCell.swift
//  ProfileSetting
//
//  Created by Yi Jerry on 2017-09-23.
//  Copyright © 2017 Yi Jerry. All rights reserved.
//

import UIKit

class profilePictureTableViewCell: UITableViewCell {

    // MARK: - When Cell Loads
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        // Initialization code
    }
    
    // MARK: - Outlets

    @IBOutlet weak var profilePhotoLabel: UILabel!

    @IBOutlet weak var profileImageView: UIImageView!
    
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state
    //    }
    
}

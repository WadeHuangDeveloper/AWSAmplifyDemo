//
//  UserAttributeTableViewCell.swift
//  AWSAmplifyDemo
//
//  Created by Huei-Der Huang on 2024/2/29.
//

import UIKit

class UserAttributeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var attributeTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  CustomCell.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 01/05/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var costLabel: UILabel!    
    
    @IBOutlet var isPickedImageView: UIImageView!
    @IBOutlet var thumbnailImage: UIImageView!
    
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var attackLabel: UILabel!
    @IBOutlet var healthLabel: UILabel!
    @IBOutlet var attackIcon: UIImageView!
    @IBOutlet var healthIcon: UIImageView!
    @IBOutlet var manaIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
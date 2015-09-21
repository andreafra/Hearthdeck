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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
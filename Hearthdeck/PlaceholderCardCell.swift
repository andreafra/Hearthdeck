//
//  PlaceholderCardCell.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 08/10/15.
//  Copyright © 2015 Qubex_. All rights reserved.
//

import UIKit

class PlaceholderCardCell: UITableViewCell {

    @IBOutlet var placeholderImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        placeholderImage.layer.cornerRadius = 27
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

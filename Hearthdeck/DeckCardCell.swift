//
//  DeckCardCell.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 15/06/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit

class DeckCardCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var quantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

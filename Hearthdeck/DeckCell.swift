//
//  DeckCell.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 20/09/15.
//  Copyright © 2015 Qubex_. All rights reserved.
//

import UIKit

class DeckCell: UITableViewCell {

    @IBOutlet var deckClassThumbnail: UIImageView!
    
    @IBOutlet var deckTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

 //
//  PlayDeckCell.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 30/06/15.
//  Copyright © 2015 Qubex_. All rights reserved.
//

import UIKit

class PlayDeckCell: UITableViewCell {

    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var quantity: UILabel!
    
    @IBOutlet var manaValue: UILabel!
    @IBOutlet var healthValue: UILabel!
    @IBOutlet var attackValue: UILabel!
    
    @IBOutlet var manaIcon: UIImageView!
    @IBOutlet var healthIcon: UIImageView!
    @IBOutlet var attackIcon: UIImageView!
    
    @IBOutlet var backCard: UIImageView!
    @IBOutlet var topCard: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        manaIcon.image = manaIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        manaIcon.tintColor = UIColor(red:0, green:0.589, blue:1, alpha:1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
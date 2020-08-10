//
//  AdoptDetailIconTextCell.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/10.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class AdoptDetailIconTextCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var shortTextLabel: UILabel! {
        didSet {
            shortTextLabel.numberOfLines = 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

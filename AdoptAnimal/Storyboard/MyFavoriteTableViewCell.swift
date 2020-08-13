//
//  MyFavoriteTableViewCell.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/12.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class MyFavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var adoptImageView: UIImageView! {
        didSet {
            adoptImageView.contentMode = .scaleAspectFill
            adoptImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var shelterNameLabel: UILabel! {
        didSet {
            shelterNameLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var shelterAddressLabel: UILabel! {
        didSet {
            shelterAddressLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var shelterTelLabel: UILabel!
    
    @IBOutlet weak var isFavoriteButton: UIButton!
    
    var adoptData: AdoptMO?
    
    func loadFavoriteData(adopt: AdoptMO) {
        
        shelterNameLabel.text = adopt.shelterName
        shelterAddressLabel.text = adopt.shelterAddress
        shelterTelLabel.text = adopt.shelterTel
        if adopt.isFavorite {
            isFavoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            isFavoriteButton.tintColor = .red
        }
        
        if let adoptImage = adopt.albumFile {
            adoptImageView.image = UIImage(data: adoptImage as Data)
        }
        
        adoptData = adopt
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

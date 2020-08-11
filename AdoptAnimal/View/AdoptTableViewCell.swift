//
//  AdoptTableViewCell.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/1.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class AdoptTableViewCell: UITableViewCell {
    
    @IBOutlet var animalKind: UILabel!
    @IBOutlet var animalColor: UILabel!
    @IBOutlet var shelterAddress: UILabel! {
        didSet {
            shelterAddress.numberOfLines = 0
        }
    }
    
    @IBOutlet var adoptImageView: UIImageView! {
        didSet {
            adoptImageView.contentMode = .scaleAspectFill
            adoptImageView.layer.cornerRadius = adoptImageView.bounds.width / 2
            adoptImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var animalSexImageView: UIImageView!
    
    private var currentAdopt: Adopt?
    
    func loadAdoptData(adopt: Adopt) {
        
        currentAdopt = adopt
        
        animalColor.text = adopt.animalColour
        shelterAddress.text = adopt.shelterAddress
        animalKind.text = adopt.animalKind.rawValue
        if let animalSex = adopt.animalSex {
            if animalSex == "M" {
                animalSexImageView.image = UIImage(named: "male")
            } else if animalSex == "F" {
                animalSexImageView.image = UIImage(named: "female")
            } else {
                animalSexImageView.image = UIImage(named: "question")
            }
        }
        guard adopt.albumFile != "" else {
            adoptImageView.image = UIImage(named: "noImage")
            return
        }
        
        if let image = CacheManager.shared.getFromCache(key: adopt.albumFile) as? UIImage {
            adoptImageView.image = image
        } else {
            if let imageUrl = URL(string: adopt.albumFile) {
                
                let downloadTask = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                    
                    guard let data = data else { return }
                    
                    OperationQueue.main.addOperation {
                        guard let image = UIImage(data: data) else { return }
                        
                        if self.currentAdopt?.albumFile == adopt.albumFile {
                            self.adoptImageView.image = image
                        }
                        
                        CacheManager.shared.cache(object: image, key: adopt.albumFile)
                    }
                }
                
                downloadTask.resume()
            }
        }
        
        //        guard let imageUrl = URL(string: adopt.albumFile) else { return }
        //        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
        //            if let data = data {
        //                DispatchQueue.main.async {
        //                    self.adoptImageView.image = UIImage(data: data)
        //                }
        //            }
        //        }.resume()
        
    }
    
}

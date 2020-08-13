//
//  AdoptDetailViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/9.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class AdoptDetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: AdoptDetailHeaderView!
    
    var adopt: Adopt?
    var adoptMO: AdoptMO?
    var imageToShare: UIImage?
    var isFavorite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        guard adopt != nil else {
            headerView.isFavoriteButton.isHidden = true
            headerView.animalKindLabel.text = adoptMO?.animalKind
            if let animalAge = adoptMO?.animalAge {
                if animalAge == "CHILD" {
                    headerView.animalAgeLabel.text = "幼年"
                } else {
                    headerView.animalAgeLabel.text = "成年"
                }
            }
            
            headerView.animalColourLabel.text = adoptMO?.animalColour
            
            guard adoptMO?.albumFile != nil else {
                headerView.animalImageView.image = UIImage(named: "noImage")
                return
            }
            if let data = adoptMO?.albumFile {
                self.headerView.animalImageView.image = UIImage(data: data)
            }
            
            return
        }
        headerView.animalKindLabel.text = adopt?.animalKind.rawValue
        if let animalAge = adopt?.animalAge {
            if animalAge == "CHILD" {
                headerView.animalAgeLabel.text = "幼年"
            } else {
                headerView.animalAgeLabel.text = "成年"
            }
        }
        
        headerView.animalColourLabel.text = adopt?.animalColour
        
        guard adopt?.albumFile != "" else {
            headerView.animalImageView.image = UIImage(named: "noImage")
            return
        }
        guard let imageUrl = URL(string: adopt!.albumFile) else { return }
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    self.headerView.animalImageView.image = UIImage(data: data)
                    self.imageToShare = UIImage(data: data)
                }
            }
        }.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func callPhone(_ sender: Any) {
        
        guard let phoneNumber = adopt?.shelterTel, let url = URL(string: "tel://\(phoneNumber)") else {
            
            let phoneNumber = adoptMO?.shelterTel
            let url = URL(string: "tel://\(phoneNumber ?? "")")
            let alert = UIAlertController(title: "提醒您", message: "即將撥打電話\(phoneNumber ?? "")", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "確定", style: .default) { (action) in
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(okayAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            
            return
        }
        let alert = UIAlertController(title: "提醒您", message: "即將撥打電話\(phoneNumber)", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "確定", style: .default) { (action) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareAnimal(_ sender: Any) {
        
        if let imageToShare = imageToShare {
            let activityController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
            
            present(activityController, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveToMyFavorite(_ sender: Any) {
        guard adopt != nil else {
            return
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            adoptMO = AdoptMO(context: appDelegate.persistentContainer.viewContext)
            adoptMO?.shelterName = adopt?.shelterName
            adoptMO?.shelterAddress = adopt?.shelterAddress
            adoptMO?.shelterTel = adopt?.shelterTel
            adoptMO?.animalAge = adopt?.animalAge
            adoptMO?.animalBacterin = adopt?.animalBacterin
            adoptMO?.animalColour = adopt?.animalColour
            adoptMO?.animalFoundplace = adopt?.animalFoundplace
            adoptMO?.animalKind = adopt?.animalKind.rawValue
            adoptMO?.animalOpendate = adopt?.animalOpendate
            adoptMO?.animalRemark = adopt?.animalRemark
            adoptMO?.animalSex = adopt?.animalSex
            adoptMO?.animalStatus = adopt?.animalStatus
            adoptMO?.animalSterilization = adopt?.animalSterilization
            adoptMO?.animalSubid = adopt?.animalSubid
            adoptMO?.cDate = adopt?.cDate
            adoptMO?.isFavorite = true
            
            if let adoptImage = imageToShare {
                adoptMO?.albumFile = adoptImage.pngData()
            }
            
            print("Saving data to context ...")
            appDelegate.saveContext()
            
            let alertController = UIAlertController(title: "提醒您", message: "浪浪已加入收藏", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension AdoptDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "動物流水編號："
            if adopt != nil {
                cell.descriptionLabel.text = adopt?.animalSubid
            } else {
                cell.descriptionLabel.text = adoptMO?.animalSubid
            }
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailIconTextCell", for: indexPath) as! AdoptDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "house")?.withRenderingMode(.alwaysOriginal)
            if adopt != nil {
                cell.shortTextLabel.text = adopt?.shelterName
            } else {
                cell.shortTextLabel.text = adoptMO?.shelterName
            }
            cell.selectionStyle = .none

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailIconTextCell", for: indexPath) as! AdoptDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "phone")?.withRenderingMode(.alwaysOriginal)
            if adopt != nil {
                cell.shortTextLabel.text = adopt?.shelterTel
            } else {
                cell.shortTextLabel.text = adoptMO?.shelterTel
            }
            cell.selectionStyle = .none

            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailIconTextCell", for: indexPath) as! AdoptDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "map")?.withRenderingMode(.alwaysOriginal)
            if adopt != nil {
                cell.shortTextLabel.text = adopt?.shelterAddress
            } else {
                cell.shortTextLabel.text = adoptMO?.shelterAddress
            }
            cell.selectionStyle = .none

            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "發現地："
            if adopt != nil {
                cell.descriptionLabel.text = adopt?.animalFoundplace
            } else {
                cell.descriptionLabel.text = adoptMO?.animalFoundplace
            }
            cell.selectionStyle = .none

            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "是否絕育："
            if adopt != nil {
                if adopt?.animalSterilization == "T" {
                    cell.descriptionLabel.text = "是"
                } else if adopt?.animalSterilization == "F" {
                    cell.descriptionLabel.text = "否"
                } else {
                    cell.descriptionLabel.text = "未輸入"
                }
            } else {
                if adoptMO?.animalSterilization == "T" {
                    cell.descriptionLabel.text = "是"
                } else if adoptMO?.animalSterilization == "F" {
                    cell.descriptionLabel.text = "否"
                } else {
                    cell.descriptionLabel.text = "未輸入"
                }
            }
            cell.selectionStyle = .none

            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailIconTextCell", for: indexPath) as! AdoptDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysOriginal)
            if adopt != nil {
                if adopt?.animalRemark != "" {
                    cell.shortTextLabel.text = adopt?.animalRemark
                } else {
                    cell.shortTextLabel.text = "無資訊"
                }
            } else {
                if adoptMO?.animalRemark != "" {
                    cell.shortTextLabel.text = adoptMO?.animalRemark
                } else {
                    cell.shortTextLabel.text = "無資訊"
                }
            }
            cell.selectionStyle = .none
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "是否開放領養："
            if adopt != nil {
                cell.descriptionLabel.text = adopt?.animalStatus
            } else {
                cell.descriptionLabel.text = adoptMO?.animalStatus
            }
            cell.selectionStyle = .none
            
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "開放認養時間："
            if adopt != nil {
                cell.descriptionLabel.text = adopt?.animalOpendate
            } else {
                cell.descriptionLabel.text = adoptMO?.animalOpendate
            }
            cell.selectionStyle = .none
            
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "資料更新時間："
            if adopt != nil {
                cell.descriptionLabel.text = adopt?.cDate
            } else {
                cell.descriptionLabel.text = adoptMO?.cDate
            }
            cell.selectionStyle = .none
            
            return cell
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
        }
    }
}

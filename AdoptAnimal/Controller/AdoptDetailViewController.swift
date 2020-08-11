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
    var imageToShare: UIImage?
    
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
        
        guard let phoneNumber = adopt?.shelterTel, let url = URL(string: "tel://\(phoneNumber)") else { return }
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
            cell.descriptionLabel.text = adopt?.animalSubid
            cell.selectionStyle = .none
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailIconTextCell", for: indexPath) as! AdoptDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "house")?.withRenderingMode(.alwaysOriginal)
            cell.shortTextLabel.text = adopt?.shelterName
            cell.selectionStyle = .none
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailIconTextCell", for: indexPath) as! AdoptDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "phone")?.withRenderingMode(.alwaysOriginal)
            cell.shortTextLabel.text = adopt?.shelterTel
            cell.selectionStyle = .none
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailIconTextCell", for: indexPath) as! AdoptDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "map")?.withRenderingMode(.alwaysOriginal)
            cell.shortTextLabel.text = adopt?.shelterAddress
            cell.selectionStyle = .none
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "發現地："
            cell.descriptionLabel.text = adopt?.animalFoundplace
            cell.selectionStyle = .none
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "是否絕育："
            if adopt?.animalSterilization == "T" {
                cell.descriptionLabel.text = "是"
            } else if adopt?.animalSterilization == "F" {
                cell.descriptionLabel.text = "否"
            } else {
                cell.descriptionLabel.text = "未輸入"
            }
            
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailIconTextCell", for: indexPath) as! AdoptDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysOriginal)
            if adopt?.animalRemark != "" {
                cell.shortTextLabel.text = adopt?.animalRemark
            } else {
                cell.shortTextLabel.text = "無資訊"
            }
            cell.selectionStyle = .none
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "是否開放領養："
            cell.descriptionLabel.text = adopt?.animalStatus
            cell.selectionStyle = .none
            
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "開放認養時間："
            cell.descriptionLabel.text = adopt?.animalOpendate
            cell.selectionStyle = .none
            
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptDetailTextCell", for: indexPath) as! AdoptDetailTextCell
            cell.subtitleTextLabel.text = "資料更新時間："
            cell.descriptionLabel.text = adopt?.cDate
            cell.selectionStyle = .none
            
            return cell
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
        }
    }
}

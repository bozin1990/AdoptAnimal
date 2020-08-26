//
//  AboutTableViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/13.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class AboutTableViewController: UITableViewController {
    
    var sectionTitles = ["回饋", "資料來源"]
    var sectionContent = [[(text: "給個評分", link: "https://www.apple.com/ios/app-store/"), (text: "意見及反饋", link: "https://medium.com/@a0930832512")], [(text: "農委會開放資料平台", link: "https://data.coa.gov.tw/Query/ServiceTransDetail.aspx?id=QcbUEzN6E6DL")]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 30, green: 136, blue: 229), NSAttributedString.Key.font: customFont]
        }
        
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sectionContent[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
        
        let cellData = sectionContent[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellData.text
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let link = sectionContent[indexPath.section][indexPath.row].link
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let appleID = "1528297743"
                if let appUrl = URL(string: "https://itunes.apple.com/us/app/itunes-u/id\(appleID)?action=write-review") {
                    UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
                }
            } else if indexPath.row == 1 {
                
                //                先判斷使用者是否有開啟內建郵件功能
                guard MFMailComposeViewController.canSendMail() else {
                    
                    let alertController = UIAlertController(title: "提醒您❗️", message: "請先在手機設定的密碼與帳號中啟用郵件功能", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    let okAction = UIAlertAction(title: "設定", style: .default) { (_) in
                        let url = URL(string: UIApplication.openSettingsURLString)
                        if let url = url, UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                let alertController = UIAlertController(title: "", message: "歡迎使用e-mail給我意見及反饋✉️", preferredStyle: .alert)
                let emailAction = UIAlertAction(title: "發送email", style: .default, handler: { (action) -> Void in
                    let mailController =  MFMailComposeViewController()
                    mailController.mailComposeDelegate = self
                    mailController.title = "意見&反饋"
                    mailController.setSubject("意見&反饋")
                    //取得forInfoDictionaryKey裡的資訊
                    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                    let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
                    let messageBody = "<br/><br/><br/>Product:\(product!)(\(version!))"
                    //寄件人
                    mailController.setMessageBody(messageBody, isHTML: true)
                    //收件人可以是多個
                    mailController.setToRecipients(["c0930832512@gmail.com"])
                    self.present(mailController, animated: true, completion: nil)
                })
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(emailAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        case 1:
            if let url = URL(string: link) {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension AboutTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result{
        case MFMailComposeResult.cancelled:
            print("user cancelled")
        case MFMailComposeResult.failed:
            print("user failed")
        case MFMailComposeResult.saved:
            print("user saved email")
        case MFMailComposeResult.sent:
            print("email sent")
        default:
            print(String(describing: error?.localizedDescription))
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

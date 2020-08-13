//
//  AboutTableViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/13.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

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
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60), NSAttributedString.Key.font: customFont]
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
        
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showWebView", sender: self)
        case 1:
            performSegue(withIdentifier: "showWebView", sender: self)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            if let destinationController = segue.destination as? WebViewController, let indexPath = tableView.indexPathForSelectedRow {
                
                destinationController.targetURL = sectionContent[indexPath.section][indexPath.row].link
            }
        }
        
    }
    

}

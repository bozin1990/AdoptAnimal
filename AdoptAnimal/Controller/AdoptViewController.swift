//
//  AdoptViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/8.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit
import UserNotifications

class AdoptViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchFooter: SearchFooter!
    @IBOutlet weak var searchFooterBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollToTopButton: UIButton!
    @IBOutlet weak var floatingButtonBottomConstraiant: NSLayoutConstraint!
    
    var adopts = [Adopt]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var filterAdopts = [Adopt]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate var isLoadingAdopt = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
        
        getAdopt()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "請輸入地址或花色"
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.tintColor = UIColor(red: 30, green: 136, blue: 229)
        searchController.searchBar.scopeButtonTitles = Adopt.AnimalKind.allCases.map { $0.rawValue }
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("取消", forKey: "cancelButtonText")
        
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 30, green: 136, blue: 229), NSAttributedString.Key.font: customFont]
        }
        
        tableView.showLoading(style: .large, color: .gray, constant: -150)
        
        addDoneButton()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tabBarController?.tabBar.isHidden = false
//        navigationController?.hidesBarsOnSwipe = true
    }
    
    func getAdopt() {
        
        let urlStr = "https://data.coa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL"
        guard let url = URL(string: urlStr) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            let decoder = JSONDecoder()
          
            if error != nil {
                let alertController = UIAlertController(title: "提醒您", message: "目前網路或資料異常，請稍後再試", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                DispatchQueue.main.async {
                    self.tableView.stopLoading()
                    self.present(alertController, animated: true, completion: nil)
                }
                
                return
            }
            if let data = data {
                do {
                    let adopts = try decoder.decode([Adopt].self, from: data)
                    self.adopts = adopts
                    DispatchQueue.main.async {
                        self.tableView.stopLoading()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func addDoneButton() {
        let toolBar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonPressed))
        doneButton.tintColor = UIColor(red: 30, green: 136, blue: 229)
        let titleLabel = UILabel()
        titleLabel.frame = view.bounds
        titleLabel.textColor = .lightGray
        titleLabel.text = "請輸入地址或花色"
        titleLabel.textAlignment = .center
        let toolBarTitle = UIBarButtonItem(customView: titleLabel)
        let lexibeSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.sizeToFit()
        toolBar.setItems([toolBarTitle, lexibeSpace, doneButton], animated: false)
        searchController.searchBar.inputAccessoryView = toolBar
    }
    
    @objc func doneButtonPressed() {
        navigationController?.view.endEditing(true)
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, category: Adopt.AnimalKind? = nil) {
        filterAdopts = adopts.filter({ (adopt: Adopt) in
            
            if let shelterAddress = adopt.shelterAddress, let animalColour = adopt.animalColour {
                
                let doesCategoryMatch = category == .all || adopt.animalKind == category
                let isMath = shelterAddress.localizedCaseInsensitiveContains(searchText) || animalColour.localizedCaseInsensitiveContains(searchText)
                
                if isSearchBarEmpty {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && isMath
                }
            }
            
            return false
        })
    }
    
    func handleKeyboard(notification: Notification) {
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
            let tabBarHeight = tabBarController?.tabBar.frame.size.height
            searchFooterBottomConstraint.constant = tabBarHeight ?? 0
            floatingButtonBottomConstraiant.constant = tabBarHeight ?? 0
            view.layoutIfNeeded()
            
            return
        }
        
        guard let info = notification.userInfo, let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.size.height
        UIView.animate(withDuration: 0.1) {
            self.searchFooterBottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
        
    }
    
    //  顯示按鈕
    func showFloatingButton() {
        UIView.animate(withDuration: 0.4) {
            self.scrollToTopButton.transform = .identity
            self.scrollToTopButton.alpha = 1
        }
    }

    // 隱藏按鈕
    func hideFloatingButton() {
        UIView.animate(withDuration: 0.4) {
            self.scrollToTopButton.transform = CGAffineTransform(translationX: 0 , y: 50)
            self.scrollToTopButton.alpha = 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 當我們的 contentOffset.y 超過我們一個 collectionView 的高度就顯示懸浮按鈕，反之則隱藏。
        if scrollView.contentOffset.y >= scrollView.bounds.height {
            showFloatingButton()
        } else {
            hideFloatingButton()
        }
    }
    
    
    
    @IBAction func scrollToTop(_ sender: UIButton) {
//        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showAdoptDetail", let indexPath = tableView.indexPathForSelectedRow, let destinationController = segue.destination as? AdoptDetailViewController else {
            return
        }
        let adopt: Adopt
        if isFiltering {
            adopt = filterAdopts[indexPath.row]
        } else {
            adopt = adopts[indexPath.row]
        }
        
        destinationController.adopt = adopt
    }
    
}

extension AdoptViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            searchFooter.setIsFilteringToShow(filteredItemCount: filterAdopts.count, of: adopts.count)
            return filterAdopts.count
        }
        
        searchFooter.setNotFiltering()
        floatingButtonBottomConstraiant.constant = 10
        return adopts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdoptTableViewCell", for: indexPath) as! AdoptTableViewCell
        let adopt: Adopt
        if isFiltering {
            adopt = filterAdopts[indexPath.row]
        } else {
            adopt = adopts[indexPath.row]
        }
        
        cell.loadAdoptData(adopt: adopt)
        
        return cell
    }
    
//    建立UIContextMenuConfiguration物件，物件包含了選單項目與預覽提供者
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
//        使用所選動物的列數來做為識別碼。
        let configuration = UIContextMenuConfiguration(identifier: indexPath.row as NSCopying, previewProvider: {
            
//            回傳預覽內容的自訂視圖控制器
            guard let adoptDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "AdoptDetailViewController") as? AdoptDetailViewController else { return nil }
            if self.isFiltering {
                let selectedAdopt = self.filterAdopts[indexPath.row]
                adoptDetailViewController.adopt = selectedAdopt
            } else {
                let selectedAdopt = self.adopts[indexPath.row]
                adoptDetailViewController.adopt = selectedAdopt
            }
            
            return adoptDetailViewController
            
        }) { action in
            
//            建立內容選單的選單項目的程式區塊
            let shareAction = UIAction(title: "分享", image: UIImage(systemName: "square.and.arrow.up")) { action in
                
                let activityController: UIActivityViewController
                if let selectCell = self.tableView.cellForRow(at: indexPath) as? AdoptTableViewCell, let adoptImage = selectCell.imageToShare {
                    
                    activityController = UIActivityViewController(activityItems: [adoptImage], applicationActivities: nil)
                    
                    self.present(activityController, animated: true, completion: nil)
                }
            }
            
            return UIMenu(title: "", children: [shareAction])
        }
        
        return configuration
    }
    
//    使用者按下預覽時顯示完整的內容
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        guard let selectedRow = configuration.identifier as? Int else {
            print("Failed to retrieve the row number")
            return
        }
        
        guard let adoptDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "AdoptDetailViewController") as? AdoptDetailViewController else { return }
        
        if self.isFiltering {
            let selectedAdopt = self.filterAdopts[selectedRow]
            adoptDetailViewController.adopt = selectedAdopt
        } else {
            let selectedAdopt = self.adopts[selectedRow]
            adoptDetailViewController.adopt = selectedAdopt
        }
        
        animator.preferredCommitStyle = .pop
        animator.addCompletion {
            self.show(adoptDetailViewController, sender: self)
        }
    }
}

extension AdoptViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let category = Adopt.AnimalKind(rawValue: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        filterContentForSearchText(searchBar.text!, category: category)
    }
}

extension AdoptViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let category = Adopt.AnimalKind(rawValue: searchBar.scopeButtonTitles![selectedScope])
        filterContentForSearchText(searchBar.text!, category: category)
    }
}

extension AdoptViewController {
    func floatingButtonShadow(_ button: UIButton) {
//        陰影偏移量
        button.layer.shadowOffset = CGSize(width: button.bounds.width / 10, height: button.bounds.width / 10)
//        陰影透明度
        button.layer.shadowOpacity = 0.7
//        陰影模糊度
        button.layer.shadowRadius = 5
//        陰影顏色
        button.layer.shadowColor = UIColor.black.cgColor
    }
    
}

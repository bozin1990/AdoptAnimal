//
//  AdoptViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/8.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class AdoptViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchFooter: SearchFooter!
    @IBOutlet weak var searchFooterBottomConstraint: NSLayoutConstraint!
    
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
        searchController.searchBar.tintColor = UIColor(red: 231, green: 76, blue: 60)
        searchController.searchBar.scopeButtonTitles = Adopt.AnimalKind.allCases.map { $0.rawValue }
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60), NSAttributedString.Key.font: customFont]
        }
        spinner.style = .medium
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150), spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        spinner.startAnimating()
        
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
        
        //        AF.request(url).validate().responseJSON { (response) in
        //            switch response.result {
        //
        //            case .success(let value):
        //                let json = JSON(value)
        //                let adoptArray = json.arrayValue
        //                var adopts = [Adopt]()
        //                for adoptJson in adoptArray {
        //                    let adopt = Adopt(json: adoptJson)
        //                    adopts.append(adopt)
        //                }
        //                self.spinner.stopAnimating()
        //                self.adopts = adopts
        //                            print(self.adopts)
        //            case .failure(let error):
        //                print(error)
        //            }
        //        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let adopts = try decoder.decode([Adopt].self, from: data)
                    self.adopts = adopts
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
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

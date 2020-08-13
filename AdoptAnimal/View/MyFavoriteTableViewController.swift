//
//  MyFavoriteTableViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/12.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit
import CoreData

class MyFavoriteTableViewController: UITableViewController {
    
    var adopts: [AdoptMO] = []
    var fetchResultController: NSFetchedResultsController<AdoptMO>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60), NSAttributedString.Key.font: customFont]
        }
        
        //         從資料儲存區中讀取資料
        let fetchRequest: NSFetchRequest<AdoptMO> = AdoptMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "shelterName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    adopts = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func isFavoriteAdopt(_ sender: Any) {

//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let indexPath = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: indexPath) as? MyFavoriteTableViewCell {
//            let context = appDelegate.persistentContainer.viewContext
//            let adoptToDelete = fetchResultController.object(at: indexPath)
//            context.delete(adoptToDelete)
//
//            adopts[indexPath.row].isFavorite = false
//
//            cell.isFavoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
//            cell.isFavoriteButton.tintColor = .lightGray
//
//            appDelegate.saveContext()
//        }

    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return adopts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFavoriteTableViewCell", for: indexPath) as! MyFavoriteTableViewCell
        let adopt = adopts[indexPath.row]
        cell.loadFavoriteData(adopt: adopt)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { (action, sourceView, completionHandler) in
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let context = appDelegate.persistentContainer.viewContext
                let adoptToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(adoptToDelete)
                
                appDelegate.saveContext()
            }
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor(red: 231, green: 76, blue: 60)
        deleteAction.image = UIImage(systemName: "trash")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectCell = tableView.cellForRow(at: indexPath) as! MyFavoriteTableViewCell
        let senderData = selectCell.adoptData
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AdoptDetailViewController") as! AdoptDetailViewController
        controller.adoptMO = senderData
        present(controller, animated: true, completion: nil)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension MyFavoriteTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            adopts = fetchedObjects as! [AdoptMO]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

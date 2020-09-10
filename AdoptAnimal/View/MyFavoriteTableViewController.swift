//
//  MyFavoriteTableViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/12.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class MyFavoriteTableViewController: UITableViewController {
    
    var adopts = [AdoptMO]() {
        didSet {
            tableView.reloadData()
        }
    }
    var fetchResultController: NSFetchedResultsController<AdoptMO>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 30, green: 136, blue: 229), NSAttributedString.Key.font: customFont]
        }
        
        //         從資料儲存區中讀取資料
        let fetchRequest: NSFetchRequest<AdoptMO> = AdoptMO.fetchRequest()
        //        ascending設定false為降冪
        let sortDescriptor = NSSortDescriptor(key: "insertDate", ascending: false)
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
        
        prepareNotification()
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
    
    func prepareNotification() {
        //        確認動物陣列不為空值
        if adopts.count <= 0 {
            return
        }
        //        隨機選擇動物
        let randomNum = Int.random(in: 0..<adopts.count)
        let suggestedAdopt = adopts[randomNum]
        
        //        建立使用者通知
        let content = UNMutableNotificationContent()
        content.title = "您收藏的浪浪"
        content.subtitle = "來看看可愛的毛孩吧！"
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-adoptAnimal.jpg")
        if let imageData = suggestedAdopt.albumFile {
            let image = UIImage(data: imageData)
            
            try? image?.jpegData(compressionQuality: 1.0)?.write(to: tempFileURL)
            if let adoptImage = try? UNNotificationAttachment(identifier: "adoptImage", url: tempFileURL, options: nil) {
                content.attachments = [adoptImage]
            }
        }
        
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 259200, repeats: false)
        let request = UNNotificationRequest(identifier: "adoptAnimal.adoptSuggestion", content: content, trigger: trigger)
        
        //        排定通知
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
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

//
//  ParksListTableViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/23/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ParksListTableViewController: UITableViewController {

    let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
    
    var coreDataStack: CoreDataStack!
    var parkItems = [ParkItem]()
    
    struct Storyboard {
        static let CellReuseIdentifier = "Park"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //fetchedResultsController.delegate = self
        
        // If local database is empty, fetch all records from cloud
        // TODO: get images but don't set them to fetchedResultsController
//        if fetchedResultsController.fetchedObjects?.count == 0 {
//            Park.fetchAllFromiCloudAndSave(coreDataStack)
//            
//            // Add observer for when cloud fetch completes
//            defaultNotificationCenter.addObserver(
//                self,
//                selector: #selector(ParksListTableViewController.fetchAllFromiCloudAndSaveNotificationHandler(_:)),
//                name: Notifications.fetchAllFromiCloudAndSaveFinishedNotification,
//                object: nil
//            )
//        }
        
        // For Development
        //Park.deleteAll(coreDataStack)
        
        parkItems = ParkItem.getAll()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Park.subscribeToiCloudChanges()
        
        defaultNotificationCenter.addObserverForName(
            CloudKitNotifications.notificationReceived,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { notification in
                if let ckQueryNotification = notification.userInfo?[CloudKitNotifications.notificationKey] as? CKQueryNotification {
                    print("in cloud kit subscription notification observer block")
                    self.iCloudHandleSubscriptionNotification(ckQueryNotification)
                }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        Park.unsubscribeToiCloudChanges()
        // TODO: remove observer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Fetched results controller
    
//    var fetchedResultsController: NSFetchedResultsController {
//        if _fetchedResultsController != nil {
//            return _fetchedResultsController!
//        }
//        
//        let fetchedResultsController = Park.getFetchedResultsController(coreDataStack)
//        fetchedResultsController.delegate = self
//        _fetchedResultsController = fetchedResultsController
//        
//        return _fetchedResultsController!
//    }
//    var _fetchedResultsController: NSFetchedResultsController? = nil {
//        didSet {
//            tableView.reloadData()
//        }
//    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath)

        let park = parkItems[indexPath.row]
        cell.textLabel?.text = park.parkName

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Notification Handling
    
    @objc private func fetchAllFromiCloudAndSaveNotificationHandler(notification: NSNotification) {
        print("iCloud fetched all records")
        //_fetchedResultsController = nil
    }
    
    private func iCloudHandleSubscriptionNotification(ckQueryNotification: CKQueryNotification) {
        print("iCloudHandleSubscriptionNotification called")
        
        // TODO: is reference to self here a memory cycle?
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            Park.updateCoreDataFromiCloudSubscriptionNotification(ckQueryNotification, coreDataStack: self.coreDataStack)
            
            dispatch_async(dispatch_get_main_queue()) {
                //self._fetchedResultsController = nil
            }
        }
        
    }

}


//extension ParksListTableViewController: NSFetchedResultsControllerDelegate {
//    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        tableView.beginUpdates()
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        
//        switch type {
//        case .Insert:
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
//        case .Delete:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
//        case .Update:
//            // TODO: handle this
////            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! HeadacheListTableViewCell
////            let headache = fetchedResultsController.objectAtIndexPath(indexPath!) as! Headache
////            configureTableCell(cell, withHeadache: headache)
//            print("updated")
//        case .Move:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
//        }
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        
//        let indexSet = NSIndexSet(index: sectionIndex)
//        
//        switch type {
//        case .Insert:
//            tableView.insertSections(indexSet, withRowAnimation: .Automatic)
//        case .Delete:
//            tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
//        default:
//            break
//        }
//    }
//
//}

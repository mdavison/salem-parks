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
    //var parkItems = [ParkItem]()
    //var parks: [Park]?
    
    struct Storyboard {
        static let CellReuseIdentifier = "Park"
        static let ShowParkDetailsSegueIdentifier = "ShowParkDetails"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        fetchedResultsController.delegate = self
        
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
        
        //parkItems = ParkItem.getAll()

        if fetchedResultsController.fetchedObjects?.count == 0 {
            print("core data is empty")
            Park.saveJSONDataToCoreData(coreDataStack)
            _fetchedResultsController = nil
        }
        
        // Theme
        tabBarController?.tabBar.tintColor = Theme.tabBarTint
        navigationController?.navigationBar.tintColor = Theme.navigationTint
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if userIsSignedIntoiCloud {
            Park.subscribeToiCloudChanges()
            
            defaultNotificationCenter.addObserverForName(
                CloudKitNotifications.notificationReceived,
                object: nil,
                queue: NSOperationQueue.mainQueue(),
                usingBlock: { notification in
                    if let ckQueryNotification = notification.userInfo?[CloudKitNotifications.notificationKey] as? CKQueryNotification {
                        self.iCloudHandleSubscriptionNotification(ckQueryNotification)
                    }
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if userIsSignedIntoiCloud {
            Park.unsubscribeToiCloudChanges()
            defaultNotificationCenter.removeObserver(CloudKitNotifications.notificationReceived)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchedResultsController = Park.getFetchedResultsController(coreDataStack)
        fetchedResultsController.delegate = self
        _fetchedResultsController = fetchedResultsController
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil {
        didSet {
            tableView.reloadData()
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return 1
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return parkItems.count
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! ParksListTableViewCell

        //let park = parkItems[indexPath.row]
        if let park = fetchedResultsController.objectAtIndexPath(indexPath) as? Park {
            //cell.textLabel?.text = park.name
            configureCell(cell, park: park)
        }

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

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ShowParkDetailsSegueIdentifier {
            let detailViewController = segue.destinationViewController as! DetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            //detailViewController.parkItem = parkItems[indexPath.row]
            detailViewController.coreDataStack = coreDataStack
            detailViewController.park = fetchedResultsController.objectAtIndexPath(indexPath) as? Park
        }
    }

    
    
    // MARK: - Notification Handling
    
//    @objc private func fetchAllFromiCloudAndSaveNotificationHandler(notification: NSNotification) {
//        print("iCloud fetched all records")
//        //_fetchedResultsController = nil
//    }
    
    private func iCloudHandleSubscriptionNotification(ckQueryNotification: CKQueryNotification) {
        print("iCloudHandleSubscriptionNotification called")
        // TODO: add a badge when new photos added
        
        // TODO: is reference to self here a memory cycle?
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            //Park.updateCoreDataFromiCloudSubscriptionNotification(ckQueryNotification, coreDataStack: self.coreDataStack)
            
            dispatch_async(dispatch_get_main_queue()) {
                //self._fetchedResultsController = nil
            }
        }
    }
    
    
    // MARK: - Helper Methods 
    
    private func configureCell(cell: ParksListTableViewCell, park: Park) {
        resetCell(cell)
        cell.parkNameLabel.text = park.name
        
        if park.hasRestrooms == true {
            cell.amenityImage1.tintColor = Theme.amenityIconHighlightColor
        }
        if park.hasPicnicTables == true {
            cell.amenityImage2.tintColor = Theme.amenityIconHighlightColor
        }
        if park.hasPicnicShelter == true {
            cell.amenityImage3.tintColor = Theme.amenityIconHighlightColor
        }
        if park.hasPlayEquip == true {
            cell.amenityImage4.tintColor = Theme.amenityIconHighlightColor
        } 
        
        if let isFavorite = park.isFavorite as? Bool {
            cell.isFavoriteImageView.hidden = !isFavorite
        }
    }
    
    private func resetCell(cell: ParksListTableViewCell) {
        cell.isFavoriteImageView.hidden = true
        cell.amenityImage1.tintColor = Theme.amenityIconDefaultColor
        cell.amenityImage2.tintColor = Theme.amenityIconDefaultColor
        cell.amenityImage3.tintColor = Theme.amenityIconDefaultColor
        cell.amenityImage4.tintColor = Theme.amenityIconDefaultColor
    }
    
}


extension ParksListTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            if let indexPath = indexPath, let cell =  tableView.cellForRowAtIndexPath(indexPath) {
                // TODO:
                //self.configureCell(cell, atIndexPath: indexPath)
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     self.tableView.reloadData()
     }
     */
    
    
}

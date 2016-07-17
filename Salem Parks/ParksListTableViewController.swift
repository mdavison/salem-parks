//
//  ParksListTableViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 6/23/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

//import UIKit
//import CoreData
//import CloudKit
//
//class ParksListTableViewController: UITableViewController {
//
//    @IBOutlet weak var searchBar: UISearchBar!
//    
//    let defaultNotificationCenter = NSNotificationCenter.defaultCenter()
//    
//    var coreDataStack: CoreDataStack!
//    var hasSearched = false
//    
//    struct Storyboard {
//        static let CellReuseIdentifier = "Park"
//        static let ShowParkDetailsSegueIdentifier = "ShowParkDetails"
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Theme
//        tabBarController?.tabBar.tintColor = Theme.tabBarTint
//        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        let searchBarCancelButton = searchBar.subviews[0].subviews[3] // UINavigationButton
//        searchBarCancelButton.tintColor = UIColor.whiteColor()
//        
//        fetchedResultsController.delegate = self
//        
//        // For Development
//        //Park.deleteAll(coreDataStack)
//
//        if fetchedResultsController.fetchedObjects?.count == 0 {
//            print("core data is empty")
//            Park.saveJSONDataToCoreData(coreDataStack)
//            _fetchedResultsController = nil
//        }
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        tableView.reloadData()
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if userIsSignedIntoiCloud {
//            //Park.unsubscribeToiCloudChanges()
//            defaultNotificationCenter.removeObserver(CloudKitNotifications.notificationReceived)
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//    // MARK: - Fetched results controller
//    
//    var fetchedResultsController: NSFetchedResultsController {
//        if _fetchedResultsController != nil {
//            return _fetchedResultsController!
//        }
//        
//        let fetchedResultsController = Park.getFetchedResultsController(nil, coreDataStack: coreDataStack)
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
//
//
//    // MARK: - Table view data source
//
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        //return 1
//        return fetchedResultsController.sections?.count ?? 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        //return parkItems.count
//        let sectionInfo = fetchedResultsController.sections![section]
//        
//        if hasSearched == true && sectionInfo.numberOfObjects == 0 {
//            // User searched and no results
//            return 1
//        }
//        return sectionInfo.numberOfObjects
//    }
//
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if fetchedResultsController.fetchedObjects?.count == 0 {
//            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
//            cell.textLabel?.text = "Nothing found"
//            cell.selectionStyle = .None
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! ParksListTableViewCell
//            if let park = fetchedResultsController.objectAtIndexPath(indexPath) as? Park {
//                configureCell(cell, park: park)
//            }
//            return cell
//        }
//    }
//
//    
//    // MARK: - Navigation
//
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == Storyboard.ShowParkDetailsSegueIdentifier {
//            let detailViewController = segue.destinationViewController as! DetailViewController
//            let indexPath = tableView.indexPathForSelectedRow!
//            
//            detailViewController.coreDataStack = coreDataStack
//            detailViewController.park = fetchedResultsController.objectAtIndexPath(indexPath) as? Park
//        }
//    }
//    
//    
//    // MARK: - Helper Methods 
//    
//    private func configureCell(cell: ParksListTableViewCell, park: Park) {
//        resetCell(cell)
//        cell.parkNameLabel.text = park.name
//        
//        if park.hasRestrooms == true {
//            cell.amenityImage1.tintColor = Theme.amenityIconHighlightColor
//        }
//        if park.hasPicnicTables == true {
//            cell.amenityImage2.tintColor = Theme.amenityIconHighlightColor
//        }
//        if park.hasPicnicShelter == true {
//            cell.amenityImage3.tintColor = Theme.amenityIconHighlightColor
//        }
//        if park.hasPlayEquip == true {
//            cell.amenityImage4.tintColor = Theme.amenityIconHighlightColor
//        } 
//        
//        if let isFavorite = park.isFavorite as? Bool {
//            cell.isFavoriteImageView.hidden = !isFavorite
//        }
//    }
//    
//    private func resetCell(cell: ParksListTableViewCell) {
//        cell.isFavoriteImageView.hidden = true
//        cell.amenityImage1.tintColor = Theme.amenityIconDefaultColor
//        cell.amenityImage2.tintColor = Theme.amenityIconDefaultColor
//        cell.amenityImage3.tintColor = Theme.amenityIconDefaultColor
//        cell.amenityImage4.tintColor = Theme.amenityIconDefaultColor
//        cell.backgroundColor = UIColor.whiteColor()
//    }
//
//}
//
//
//extension ParksListTableViewController: NSFetchedResultsControllerDelegate {
//    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        self.tableView.beginUpdates()
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//        case .Insert:
//            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        case .Delete:
//            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        default:
//            return
//        }
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//        case .Insert:
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        case .Delete:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//        case .Update:
//            break
//        case .Move:
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        }
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        self.tableView.endUpdates()
//    }
//    
//    /*
//     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
//     
//     func controllerDidChangeContent(controller: NSFetchedResultsController) {
//     // In the simplest, most efficient, case, reload the table view.
//     self.tableView.reloadData()
//     }
//     */
//    
//}
//
//
//extension ParksListTableViewController: UISearchBarDelegate {
//    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        //print("The search text is: '\(searchBar.text!)'")
//        searchBar.resignFirstResponder()
//        hasSearched = true
//        _fetchedResultsController = Park.getFetchedResultsController(searchBar.text, coreDataStack: coreDataStack)
//    }
//    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        hasSearched = false
//        _fetchedResultsController = Park.getFetchedResultsController(nil, coreDataStack: coreDataStack)
//    }
//    
//}
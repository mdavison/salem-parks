//
//  ParksListViewController.swift
//  Salem Parks
//
//  Created by Morgan Davison on 7/16/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ParksListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var coreDataStack: CoreDataStack!
    var hasSearched = false
    
    struct Storyboard {
        static let CellReuseIdentifier = "Park"
        static let ShowParkDetailsSegueIdentifier = "ShowParkDetails"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Theme
        tabBarController?.tabBar.tintColor = Theme.tabBarTint
        navigationController?.navigationBar.tintColor = UIColor.white
        let searchBarCancelButton = searchBar.subviews[0].subviews[2] // UINavigationButton
        searchBarCancelButton.tintColor = UIColor.white
        
        fetchedResultsController.delegate = self
        
        // For Development
        //Park.deleteAll(coreDataStack)
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            print("core data is empty")
            Park.saveJSONDataToCoreData(coreDataStack)
            _fetchedResultsController = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchedResultsController = Park.getFetchedResultsController(nil, category: segmentedControl.selectedSegmentIndex, coreDataStack: coreDataStack)
        fetchedResultsController.delegate = self
        _fetchedResultsController = fetchedResultsController
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ShowParkDetailsSegueIdentifier {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            
            detailViewController.coreDataStack = coreDataStack
            detailViewController.park = fetchedResultsController.object(at: indexPath) as? Park
        }
    }
    
    
    // MARK: - Helper Methods
    
    fileprivate func configureCell(_ cell: ParksListTableViewCell, park: Park) {
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
            cell.isFavoriteImageView.isHidden = !isFavorite
        }
    }
    
    fileprivate func resetCell(_ cell: ParksListTableViewCell) {
        cell.isFavoriteImageView.isHidden = true
        cell.amenityImage1.tintColor = Theme.amenityIconDefaultColor
        cell.amenityImage2.tintColor = Theme.amenityIconDefaultColor
        cell.amenityImage3.tintColor = Theme.amenityIconDefaultColor
        cell.amenityImage4.tintColor = Theme.amenityIconDefaultColor
        cell.backgroundColor = UIColor.white
    }

    fileprivate func performSearch() {
        searchBar.resignFirstResponder()
        
        var searchText: String?
        if let text = searchBar.text {
            if !text.isEmpty && text != "" {
                searchText = searchBar.text
            }
        }
        
        _fetchedResultsController = Park.getFetchedResultsController(searchText, category: segmentedControl.selectedSegmentIndex, coreDataStack: coreDataStack)
    }

}


extension ParksListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        if hasSearched == true && sectionInfo.numberOfObjects == 0 {
            // User searched and no results
            return 1
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Nothing found"
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseIdentifier, for: indexPath) as! ParksListTableViewCell
            if let park = fetchedResultsController.object(at: indexPath) as? Park {
                configureCell(cell, park: park)
            }
            return cell
        }
    }
}


extension ParksListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            break
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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


extension ParksListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
        hasSearched = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        performSearch()
        hasSearched = false
    }
    
}



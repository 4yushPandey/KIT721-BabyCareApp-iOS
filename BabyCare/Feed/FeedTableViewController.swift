//
//  FeedTableViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 2/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift


// Tutorial 8 and 9

class FeedTableViewController: UITableViewController {
    var feeds = [Feed]()
    
    @IBAction func unwindToFeedList(sender: UIStoryboardSegue)
    {
        //we could reload from db, but lets just trust the local movie object
        if let detailScreen = sender.source as? FeedDetailViewController
        {
            feeds[detailScreen.feedIndex!] = detailScreen.feed!
            tableView.reloadData()
        }
        
    }
    
    
    

    @IBAction func unwindToFeedListWithCancel(sender: UIStoryboardSegue)
    {
        tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let db = Firestore.firestore()
                let feedCollection = db.collection("feedingHistory")
                feedCollection.getDocuments() { (result, err) in
                    if let err = err
                    {
                        print("Error getting documents: \(err)")
                    }
                    else
                    {
                        for document in result!.documents
                        {
                            let conversionResult = Result
                            {
                                try document.data(as: Feed.self)
                            }
                            switch conversionResult
                            {
                                case .success(let feed):
                                    print("Feed: \(feed)")
                                        
                                    //NOTE THE ADDITION OF THIS LINE
                                    self.feeds.append(feed)
                                    
                                case .failure(let error):
                                    // A `feed` value could not be initialized from the DocumentSnapshot.
                                    print("Error decoding feeding data: \(error)")
                            }
                        }
                        
                        //NOTE THE ADDITION OF THIS LINE
                        self.tableView.reloadData()
                        
                    }
                }
                
            }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath)

        //get the feed for this row
        let feed = feeds[indexPath.row]

        //down-cast the cell from UITableViewCell to our cell class feedUITableViewCell
        //note, this could fail, so we use an if let.
        if let feedCell = cell as? FeedTableViewCell
        {
            //populate the cell
            feedCell.feedDateLabel.text = feed.feedDate + "----------" + feed.feedStartTime
            feedCell.milkTypeLabel.text = feed.milkType
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        // is this the segue to the details screen? (in more complex apps, there is more than one segue per screen)
        if segue.identifier == "ShowFeedDetailSegue"
        {
              //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
              guard let detailViewController = segue.destination as? FeedDetailViewController else
              {
                  fatalError("Unexpected destination: \(segue.destination)")
              }

              //down-cast from UITableViewCell to feedUITableViewCell (this could fail if we didn’t link things up properly)
              guard let selectedFeedCell = sender as? FeedTableViewCell else
              {
                  fatalError("Unexpected sender: \( String(describing: sender))")
              }

              //get the number of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
              guard let indexPath = tableView.indexPath(for: selectedFeedCell) else
              {
                  fatalError("The selected cell is not being displayed by the table")
              }

              //work out which feed it is using the row number
              let selectedFeed = feeds[indexPath.row]

              //send it to the details screen
              detailViewController.feed = selectedFeed
              detailViewController.feedIndex = indexPath.row
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowFeedDetailSegue", sender: tableView.cellForRow(at: indexPath))
    }

    func fetchFeedsData() {
        let db = Firestore.firestore()
        let feedCollection = db.collection("feedingHistory")
        
        feedCollection.getDocuments() { [weak self] (result, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self?.feeds.removeAll() // Clear the existing data
            
                for document in result!.documents {
                    let conversionResult = Result {
                        try document.data(as: Feed.self)
                    }
                    switch conversionResult {
                    case .success(let feed):
                        print("Feed: \(feed)")
                        self?.feeds.append(feed)
                    case .failure(let error):
                        print("Error decoding feeding data: \(error)")
                    }
                }
                
                self?.tableView.reloadData() // Reload the table view with new data
            }
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

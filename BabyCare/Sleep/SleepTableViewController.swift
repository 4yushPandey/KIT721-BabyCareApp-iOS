//
//  SleepTableViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 4/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift



class SleepTableViewController: UITableViewController {
    var sleeps = [Sleep]()
    
    @IBAction func unwindToSleepList(sender: UIStoryboardSegue)
    {
        //we could reload from db, but lets just trust the local movie object
        if let detailScreen = sender.source as? SleepDetailViewController
        {
            sleeps[detailScreen.sleepIndex!] = detailScreen.sleep!
            tableView.reloadData()
        }
    }

    @IBAction func unwindToSleepListWithCancel(sender: UIStoryboardSegue)
    {
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let db = Firestore.firestore()
               let movieCollection = db.collection("sleepHistory")
               movieCollection.getDocuments() { (result, err) in
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
                               try document.data(as: Sleep.self)
                           }
                           switch conversionResult
                           {
                               case .success(let sleep):
                                   print("Sleep: \(sleep)")
                                       
                                   //NOTE THE ADDITION OF THIS LINE
                                   self.sleeps.append(sleep)
                                   
                               case .failure(let error):
                                   // A `Movie` value could not be initialized from the DocumentSnapshot.
                                   print("Error decoding sleep data: \(error)")
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
        return sleeps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SleepTableViewCell", for: indexPath)

        //get the movie for this row
        let sleep = sleeps[indexPath.row]

        //down-cast the cell from UITableViewCell to our cell class MovieUITableViewCell
        //note, this could fail, so we use an if let.
        if let sleepCell = cell as? SleepTableViewCell
        {
            //populate the cell
            sleepCell.sleepStartLabel.text = sleep.sleepStart
            sleepCell.sleepEndLabel.text = sleep.sleepEnd
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        // is this the segue to the details screen? (in more complex apps, there is more than one segue per screen)
        if segue.identifier == "ShowSleepDetailSegue"
        {
              //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
              guard let detailViewController = segue.destination as? SleepDetailViewController else
              {
                  fatalError("Unexpected destination: \(segue.destination)")
              }

              //down-cast from UITableViewCell to MovieUITableViewCell (this could fail if we didn’t link things up properly)
              guard let selectedSleepCell = sender as? SleepTableViewCell else
              {
                  fatalError("Unexpected sender: \( String(describing: sender))")
              }

              //get the number of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
              guard let indexPath = tableView.indexPath(for: selectedSleepCell) else
              {
                  fatalError("The selected cell is not being displayed by the table")
              }

              //work out which movie it is using the row number
              let selectedSleep = sleeps[indexPath.row]

              //send it to the details screen
              detailViewController.sleep = selectedSleep
              detailViewController.sleepIndex = indexPath.row
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSleepDetailSegue", sender: tableView.cellForRow(at: indexPath))
    }
    
    func fetchSleepsData(){
        let db = Firestore.firestore()
               let movieCollection = db.collection("sleepHistory")
               movieCollection.getDocuments() { [weak self] (result, err) in
                   if let err = err {
                       print("Error getting documents: \(err)")
                   } else {
                       self?.sleeps.removeAll()
                       for document in result!.documents
                       {
                           let conversionResult = Result
                           {
                               try document.data(as: Sleep.self)
                           }
                           switch conversionResult
                           {
                               case .success(let sleep):
                                   print("Sleep: \(sleep)")
                                       
                                   //NOTE THE ADDITION OF THIS LINE
                                   self?.sleeps.append(sleep)
                                   
                               case .failure(let error):
                                   // A `Movie` value could not be initialized from the DocumentSnapshot.
                                   print("Error decoding sleep data: \(error)")
                           }
                       }
                       
                       //NOTE THE ADDITION OF THIS LINE
                       self?.tableView.reloadData()
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

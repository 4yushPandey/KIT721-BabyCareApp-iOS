//
//  FeedDetailViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 8/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift


// https://www.youtube.com/watch?v=FWBqdOjZ2S4 - How to use UISegmentControl
// Asked ChatGPT "How to get string of current date and time in swift"
// Tutorial 8 and 9

protocol FeedDetailViewControllerDelegate: AnyObject {
    func feedDetailViewControllerDidDeleteFeed(_ viewController: FeedDetailViewController)
}



class FeedDetailViewController: UIViewController {

    
    let db = Firestore.firestore()

    var feed : Feed?
    var feedIndex : Int?
    var milkTypePicked: String = ""
    var feedDatePicked: String = ""
    var feedTimePicked: String = ""
    var feedSidePicked: String = ""
    // Properties
    var timer = Timer()
    var isTimerRunning = false
    var elapsedTime: TimeInterval = 0
    

    @IBOutlet weak var timerBtn: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var feedNoteLabel: UITextField!
    @IBOutlet weak var quantityLabel: UITextField!
    

    @IBOutlet weak var feedSidePicker: UISegmentedControl!
    @IBOutlet weak var milkTypePicker: UISegmentedControl!
    @IBOutlet weak var feedDatePicker: UIDatePicker!
    
    @IBOutlet weak var feedTimePicker: UIDatePicker!
    
    @IBAction func onDelete(_ sender: UIButton) {
      
        let db = Firestore.firestore()
        let alertController = UIAlertController(title: "Feed Data Delete", message: "Are you sure you want to delete", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (_) in
                self?.deleteFeedData()
            }))
            
            present(alertController, animated: true, completion: nil)
        }
    
    func deleteFeedData() {
        guard let feedID = feed?.documentID else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("feedingHistory").document(feedID).delete { [weak self] error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Document successfully deleted")

                
                // Notify the previous view controller to fetch the updated growth data
                if let feedTableViewController = self?.navigationController?.viewControllers.first as? FeedTableViewController {
                    feedTableViewController.fetchFeedsData()
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func timerButtonTapped(_ sender: UIButton) {
        
        if isTimerRunning {
                   // Stop timer
                   timer.invalidate()
                   isTimerRunning = false
            timerBtn.setTitle("Start", for: .normal)
               } else {
                   // Start timer
                   timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                   isTimerRunning = true
                   timerBtn.setTitle("Stop", for: .normal)
               }
    }
    @objc func updateTimer() {
        elapsedTime += 0.1
        timerLabel.text = String(format: "%.1f", elapsedTime)
    }
    @IBAction func feedSideChanged(_ sender: Any) {
        switch feedSidePicker.selectedSegmentIndex {
            case 0:
            feedSidePicked = "Left Side"
                break
            case 1:
            feedSidePicked = "Right Side"
                // Second segment selected
                break
            default:
            feedSidePicked = "Right Side"
                break
            }
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // customize the format to your liking
        let dateString = dateFormatter.string(from: sender.date)
        feedDatePicked = dateString
    }
    
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Set the time style
        let selectedTime = timeFormatter.string(from: sender.date)
        feedTimePicked = "\(selectedTime)"
        
    }
    @IBAction func milkTypeChanged(_ sender: Any) {
        switch milkTypePicker.selectedSegmentIndex {
            case 0:
                milkTypePicked = "Mothers Milk"
                break
            case 1:
                milkTypePicked = "Bottle Milk"
                // Second segment selected
                break
            default:
                milkTypePicked = "Mothers Milk"
                break
            }
    }
    
    
    @IBAction func onSave(_ sender: Any) {
        (sender as! UIBarButtonItem).title = "Loading..."

           let db = Firestore.firestore()
        
        switch milkTypePicker.selectedSegmentIndex {
        case 0:
            milkTypePicked = "Mothers Milk"
        case 1:
            milkTypePicked = "Bottle Milk"
        default:
            showAlert(message: "Please select a milk type.")
            return
        }
        
         switch feedSidePicker.selectedSegmentIndex {
         case 0:
             feedSidePicked = "Left Side"
         case 1:
             feedSidePicked = "Right Side"
         default:
             showAlert(message: "Please select a feed side.")
             return
         }
        
        guard let quantityText = quantityLabel.text, !quantityText.isEmpty else {
            showAlert(message: "Please enter a quantity.")
            return
        }
        
        
        // Get the selected date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: feedDatePicker.date)
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let selectedTime = timeFormatter.string(from: feedTimePicker.date)
        
        
        feed?.feedDate = dateString
        feed?.feedStartTime = selectedTime
        feed?.milkType = milkTypePicked
        feed?.feedDuration = timerLabel.text!
        feed?.quantity = quantityText
        feed?.feedSide = feedSidePicked
        feed?.feedNote = feedNoteLabel.text ?? "Note"
        
        do
            {
                //update the database (code from lectures)
                try db.collection("feedingHistory").document(feed!.documentID!).setData(from: feed!){ err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        //this code triggers the unwind segue manually
                        self.performSegue(withIdentifier: "saveSegue", sender: sender)
                        
                    }
                }
            } catch { print("Error updating document \(error)") } //note "error" is a magic variable
        }

    
    
    @IBAction func onShare(_ sender: Any) {
        let shareViewController = UIActivityViewController(activityItems: [feedDatePicked,feedTimePicked,feedSidePicked, milkTypePicked,timerLabel.text!,quantityLabel.text!,feedNoteLabel.text!], applicationActivities: [])
        shareViewController.popoverPresentationController?.sourceView = (sender as! UIView) // so that iPads won't crash
        shareViewController.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook]
        present(shareViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Set the selected segment index for milkType
           milkTypePicker.selectedSegmentIndex = 0 // Select the first segment by default
           
           // Set the selected segment index for feedSide
           feedSidePicker.selectedSegmentIndex = 0
           feedDatePicked = getCurrentDate()
           feedTimePicked = getCurrentTime()

        if let displayFeed = feed
        {
            self.navigationItem.title = displayFeed.feedStartTime //this awesome line sets the page title
            quantityLabel.text = displayFeed.quantity
            timerLabel.text = displayFeed.feedDuration
            feedNoteLabel.text = displayFeed.feedNote
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"

            // Get the string value representing the date
            let dateString = displayFeed.feedDate

            // Convert the string to a Date object
            if let date = dateFormatter.date(from: dateString) {
                // Set the date picker's date
                feedDatePicker.date = date
            }
            
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            feedTimePicker.date = timeFormatter.date(from: displayFeed.feedStartTime)!
            
            
            for index in 0..<milkTypePicker.numberOfSegments {
                if let segmentValue = milkTypePicker.titleForSegment(at: index), segmentValue == displayFeed.milkType {
                    milkTypePicker.selectedSegmentIndex = index
                    break
                }
            }
            for index in 0..<feedSidePicker.numberOfSegments {
                if let segmentValue = feedSidePicker.titleForSegment(at: index), segmentValue == displayFeed.feedSide {
                    feedSidePicker.selectedSegmentIndex = index
                    break
                }
            }
        }
    }
    
    func getCurrentDate() -> String{
        let currentDate = Date()  // Get the current date and time
        let dateFormatter = DateFormatter()  // Create a date formatter
        dateFormatter.dateFormat = "MM/dd/yyyy"  // Set the date format
        let dateString = dateFormatter.string(from: currentDate)
        
        return dateString
    }
    
    func getCurrentTime() -> String{
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Set the time style
        let selectedTime = timeFormatter.string(from: Date())
        return selectedTime
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
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

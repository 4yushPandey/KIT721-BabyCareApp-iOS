//
//  AddFeedViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 13/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AddFeedViewController: UIViewController {

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
    
    
    
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var feedSide: UISegmentedControl!
    @IBOutlet weak var milkType: UISegmentedControl!
    @IBOutlet weak var time: UIDatePicker!
    @IBOutlet weak var date: UIDatePicker!
    
    @IBAction func onSave(_ sender: Any) {
        
        switch milkType.selectedSegmentIndex {
        case 0:
            milkTypePicked = "Mothers Milk"
        case 1:
            milkTypePicked = "Bottle Milk"
        default:
            showAlert(message: "Please select a milk type.")
            return
        }
        
         switch feedSide.selectedSegmentIndex {
         case 0:
             feedSidePicked = "Left Side"
         case 1:
             feedSidePicked = "Right Side"
         default:
             showAlert(message: "Please select a feed side.")
             return
         }
        
        guard let quantityText = quantity.text, !quantityText.isEmpty else {
            showAlert(message: "Please enter a quantity.")
            return
        }
        
        
        // Get the selected date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: date.date)
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let selectedTime = timeFormatter.string(from: time.date)
        
        
        let movieCollection = db.collection("feedingHistory")
        let matrix = Feed(
                    feedDate: dateString,
                    feedStartTime: selectedTime,
                    milkType: milkTypePicked,
                    feedSide: feedSidePicked,
                    feedDuration: timerLabel.text!,
                    quantity: quantityText,
                    feedNote: note.text!
            )
        do {
            try movieCollection.addDocument(from: matrix, completion: { [self] (err) in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Successfully created movie")
                    let alertController = UIAlertController(title: "Feed Data Added", message: "Feed Data was successfully added", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                                        self?.navigationController?.popViewController(animated: true)
                                    }))
                    
                    guard let feedTableViewController = navigationController?.viewControllers.first as? FeedTableViewController else {
                        return
                    }

                    feedTableViewController.fetchFeedsData()
                    
                    present(alertController, animated: true, completion: nil)
                }
            })
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
        
    }
    
    
    
    @IBAction func timerButtonTapped(_ sender: Any) {
        if isTimerRunning {
                   // Stop timer
                   timer.invalidate()
                   isTimerRunning = false
            timerButton.setTitle("Start", for: .normal)
               } else {
                   // Start timer
                   timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                   isTimerRunning = true
                   timerButton.setTitle("Stop", for: .normal)
               }
    }
    
    @objc func updateTimer() {
        elapsedTime += 0.1
        timerLabel.text = String(format: "%.1f", elapsedTime)
    }
    
    @IBAction func milkTypeChanged(_ sender: Any) {
        switch milkType.selectedSegmentIndex {
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
    
    @IBAction func feedSideChanged(_ sender: Any) {
        switch feedSide.selectedSegmentIndex {
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
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // customize the format to your liking
        let dateString = dateFormatter.string(from: sender.date)
        feedDatePicked = dateString
    }
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Set the time style
        let selectedTime = timeFormatter.string(from: sender.date)
        feedTimePicked = "\(selectedTime)"
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the selected segment index for milkType
           milkType.selectedSegmentIndex = 0 // Select the first segment by default
           
           // Set the selected segment index for feedSide
           feedSide.selectedSegmentIndex = 0
           feedDatePicked = getCurrentDate()
           feedTimePicked = getCurrentTime()
           
        // Do any additional setup after loading the view.
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

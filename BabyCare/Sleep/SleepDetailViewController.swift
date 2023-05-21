//
//  SleepDetailViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 12/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class SleepDetailViewController: UIViewController {
    let db = Firestore.firestore()
    var sleep : Sleep?
    var sleepIndex : Int? //used much later in tutorial
    var datePicked: String = ""
    var startTimePicked: String = ""
    var endTimePicked: String = ""
    var timer = Timer()
    var isTimerRunning = false
    var elapsedTime: TimeInterval = 0
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var note: UITextField!
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // customize the format to your liking
        let dateString = dateFormatter.string(from: sender.date)
        datePicked = dateString
    }
    
    
    @IBAction func startTimerPickerChanged(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Set the time style
        let selectedTime = timeFormatter.string(from: sender.date)
        startTimePicked = "\(selectedTime)"
    }
    
    @IBAction func endTimerPickerChanged(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Set the time style
        let selectedTime = timeFormatter.string(from: sender.date)
        endTimePicked = "\(selectedTime)"
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
    
    @IBAction func onSave(_ sender: Any) {
        
        (sender as! UIBarButtonItem).title = "Loading..."


        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: datePicker.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let startselectedTime = timeFormatter.string(from: startTimePicker.date)
        let endselectedTime = timeFormatter.string(from: endTimePicker.date)
        
        
        sleep!.date = dateString
        sleep!.sleepStart = startselectedTime
        sleep!.sleepEnd = endselectedTime
        sleep!.sleepNote = note.text
        sleep!.sleepDuration = timerLabel.text

        do
            {
                //update the database (code from lectures)
                try db.collection("sleepHistory").document(sleep!.documentID!).setData(from: sleep!){ err in
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
    
    
    @IBAction func onDelete(_ sender: Any) {
        let db = Firestore.firestore()
        let alertController = UIAlertController(title: "Sleep Data Delete", message: "Are you sure you want to delete", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (_) in
                self?.deleteSleepData()
            }))
            
            present(alertController, animated: true, completion: nil)
    }
    
    func deleteSleepData() {
        guard let sleepID = sleep?.documentID else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("sleepHistory").document(sleepID).delete { [weak self] error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Growth data deleted successfully")
            
                // Notify the previous view controller to fetch the updated growth data
                if let sleepTableViewController = self?.navigationController?.viewControllers.first as? SleepTableViewController {
                    sleepTableViewController.fetchSleepsData()
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func onShare(_ sender: Any) {
        let shareViewController = UIActivityViewController(activityItems: [datePicked,startTimePicked,endTimePicked,timerLabel.text!,note.text!], applicationActivities: [])
        shareViewController.popoverPresentationController?.sourceView = (sender as! UIView) // so that iPads won't crash
        shareViewController.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook]
        present(shareViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicked = getCurrentDate()
        startTimePicked = getCurrentTime()
        endTimePicked = getCurrentDate()
        
        if let displaySleep = sleep
        {
            self.navigationItem.title = displaySleep.sleepStart //this awesome line sets the page title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"

            // Get the string value representing the date
            let dateString = displaySleep.date
            // Convert the string to a Date object
            if let date = dateFormatter.date(from: dateString) {
                // Set the date picker's date
                datePicker.date = date
            }
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            startTimePicker.date = timeFormatter.date(from: displaySleep.sleepStart)!
            endTimePicker.date = timeFormatter.date(from: displaySleep.sleepEnd!)!
            
            timerLabel.text = displaySleep.sleepDuration
            
            
        }

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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  AddSleepViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 13/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AddSleepViewController: UIViewController {

    let db = Firestore.firestore()
    
    var datePicked: String = ""
    var startTimePicked: String = ""
    var endTimePicked: String = ""
    var timer = Timer()
    var isTimerRunning = false
    var elapsedTime: TimeInterval = 0
    @IBOutlet weak var note: UITextField!
 
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
  
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // customize the format to your liking
        let dateString = dateFormatter.string(from: sender.date)
        datePicked = dateString
    }
    @IBAction func startTimeChanged(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Set the time style
        let selectedTime = timeFormatter.string(from: sender.date)
        startTimePicked = "\(selectedTime)"
    }
    @IBAction func endTimeChanged(_ sender: UIDatePicker) {
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: datePicker.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let startselectedTime = timeFormatter.string(from: startTimePicker.date)
        let endselectedTime = timeFormatter.string(from: endTimePicker.date)
        
        
        
        let sleepCollection = db.collection("sleepHistory")
        let sleepData = Sleep(date: dateString, sleepStart: startselectedTime, sleepEnd: endselectedTime, sleepNote: note.text, sleepDuration: timerLabel.text)
        // Get the selected date and time
        

        do {
            try sleepCollection.addDocument(from: sleepData, completion: { [self] (err) in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Successfully created sleep")
                    let alertController = UIAlertController(title: "Sleep Data Added", message: "Sleep Data was successfully added", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                                        self?.navigationController?.popViewController(animated: true)
                                    }))
                    
                    guard let sleepTableViewController = navigationController?.viewControllers.first as? SleepTableViewController else {
                        return
                    }

                    sleepTableViewController.fetchSleepsData()
                    present(alertController, animated: true, completion: nil)
                    
                }
            })
        } catch let error {
            print("Error writing sleep data to Firestore: \(error)")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        datePicked = getCurrentDate()
        startTimePicked = getCurrentTime()
        endTimePicked = getCurrentTime()
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

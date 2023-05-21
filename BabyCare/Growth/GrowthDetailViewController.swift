//
//  GrowthDetailViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 12/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class GrowthDetailViewController: UIViewController {
    
    
    let db = Firestore.firestore()
    var measuredDatePicked: String = ""
    var growth : Growth?
    var growthIndex : Int?
    let heightPickerDelegate = HeightPickerDelegate()

    
    @IBOutlet weak var heightPicker: UIPickerView!
    
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var measuredDatePicker: UIDatePicker!
    
    @IBAction func measuredDateChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy" // customize the format to your liking
            measuredDatePicked = dateFormatter.string(from: measuredDatePicker.date)
    }
    
    
    
    @IBAction func onShare(_ sender: Any) {
        let shareViewController = UIActivityViewController(activityItems: [measuredDatePicked,heightTextField.text as Any], applicationActivities: [])
        shareViewController.popoverPresentationController?.sourceView = (sender as! UIView) // so that iPads won't crash
        shareViewController.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook]
        present(shareViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func onSave(_ sender: Any) {
        (sender as! UIBarButtonItem).title = "Loading..."


        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: measuredDatePicker.date)
        
        growth?.measuredDate = dateString
        growth?.height = heightTextField.text!
        
        do
            {
                //update the database (code from lectures)
                try db.collection("growthHistory").document(growth!.documentID!).setData(from: growth!){ err in
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
        let alertController = UIAlertController(title: "Growth Data Delete", message: "Are you sure you want to delete", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (_) in
                self?.deleteGrowthData()
            }))
            
            present(alertController, animated: true, completion: nil)

    }
    
    private func deleteGrowthData() {
        guard let growth = growth else {
            return
        }
        
        db.collection("growthHistory").document(growth.documentID!).delete { [weak self] error in
            if let error = error {
                print("Error deleting growth data: \(error)")
            } else {
                print("Growth data deleted successfully")
            
                // Notify the previous view controller to fetch the updated growth data
                if let growthTableViewController = self?.navigationController?.viewControllers.first as? GrowthTableViewController {
                    growthTableViewController.fetchGrowthData()
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        measuredDatePicked = getCurrentDate()
        heightPicker.delegate = heightPickerDelegate
        heightPicker.dataSource = heightPickerDelegate
        
        heightTextField.inputView = heightPicker
        heightTextField.inputAccessoryView = createToolbar()
        
        // Set initial text field value
        heightTextField.text = "\(heightPickerDelegate.selectedFeet) ft \(heightPickerDelegate.selectedInches) in"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(heightTextFieldTapped))
        heightTextField.addGestureRecognizer(tapGesture)
        heightPicker.isHidden = true
        if let displayGrowth = growth
        {
            self.navigationItem.title = displayGrowth.measuredDate //this awesome line sets the page title
            print(displayGrowth.height)
            print(displayGrowth.measuredDate)
            
            let heightComponents = displayGrowth.height.components(separatedBy: .whitespacesAndNewlines)
            if heightComponents.count >= 3 {
                let feetString = heightComponents[0]
                let inchesString = heightComponents[2]
                
                if let feet = Int(feetString), let inches = Int(inchesString) {
                    heightPicker.selectRow(feet, inComponent: 0, animated: false)
                    heightPicker.selectRow(inches, inComponent: 1, animated: false)
                    
                    let selectedFeet = heightPickerDelegate.feet[feet]
                    let selectedInches = heightPickerDelegate.inches[inches]
                    
                    heightTextField.text = "\(selectedFeet) ft \(selectedInches) in"
                }
                
                let heightComponents = displayGrowth.height.components(separatedBy: .whitespacesAndNewlines)
                if heightComponents.count >= 3 {
                    if let feetString = heightComponents.first, let inchesString = heightComponents.last,
                       let selectedFeet = Int(feetString), let selectedInches = Int(inchesString),
                       let selectedFeetIndex = heightPickerDelegate.feet.firstIndex(of: selectedFeet),
                       let selectedInchesIndex = heightPickerDelegate.inches.firstIndex(of: selectedInches) {
                        
                        heightPicker.selectRow(selectedFeetIndex, inComponent: 0, animated: false)
                        heightPicker.selectRow(selectedInchesIndex, inComponent: 1, animated: false)
                        
                        heightTextField.text = "\(selectedFeet) ft \(selectedInches) in"
                    }
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    
                    // Get the string value representing the date
                    let dateString = displayGrowth.measuredDate
                    
                    // Convert the string to a Date object
                    if let date = dateFormatter.date(from: dateString) {
                        // Set the date picker's date
                        measuredDatePicker.date = date
                    }
                }
            }
            
        }}
    @objc func heightTextFieldTapped() {
            heightTextField.becomeFirstResponder()
        heightPicker.isHidden = false
        }
        
        func createToolbar() -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()

            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
            toolbar.setItems([doneButton], animated: true)

            return toolbar
        }
        
        @objc func doneButtonTapped() {
            heightTextField.resignFirstResponder()
            
            let selectedFeet = heightPickerDelegate.selectedFeet
            let selectedInches = heightPickerDelegate.selectedInches
            
            let height = "\(selectedFeet) ft \(selectedInches) in"
            heightTextField.text = height
        }
    
    func getCurrentDate() -> String{
        let currentDate = Date()  // Get the current date and time
        let dateFormatter = DateFormatter()  // Create a date formatter
        dateFormatter.dateFormat = "MM/dd/yyyy"  // Set the date format
        let dateString = dateFormatter.string(from: currentDate)
        
        return dateString
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



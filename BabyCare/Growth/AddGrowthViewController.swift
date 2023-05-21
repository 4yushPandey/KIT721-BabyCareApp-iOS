//
//  AddGrowthViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 13/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AddGrowthViewController: UIViewController {
    
    let db = Firestore.firestore()
    var measuredDatePicked: String = ""
    var growth : Growth?
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var heightPicker: UIPickerView!
    let heightPickerDelegate = HeightPickerDelegate()
    @IBOutlet weak var measuredDatePicker: UIDatePicker!
    
    @IBAction func measuredDateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy" // customize the format to your liking
            measuredDatePicked = dateFormatter.string(from: measuredDatePicker.date)
    }
    
    @IBAction func onSave(_ sender: Any) {
        let growthCollection = db.collection("growthHistory")
        let growth = Growth(height: heightTextField.text!, measuredDate: measuredDatePicked)
        do {
            try growthCollection.addDocument(from: growth, completion: { [self] (err) in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Successfully created growth data")
                    let alertController = UIAlertController(title: "Growth Data Added", message: "Growth Data was successfully added", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                                        self?.navigationController?.popViewController(animated: true)
                                    }))
                    
                    guard let growthTableViewController = navigationController?.viewControllers.first as? GrowthTableViewController else {
                        return
                    }

                    growthTableViewController.fetchGrowthData()
                    present(alertController, animated: true, completion: nil)
                }
            })
        } catch let error {
            print("Error writing city to Firestore: \(error)")
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
        
        // Hide the picker initially
            heightPicker.isHidden = true
        
        
    }
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
    
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



class HeightPickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let feet: [Int] = Array(0...8)
    let inches: [Int] = Array(0...12)
    
    var selectedFeet: Int = 0
    var selectedInches: Int = 0
    
    override init() {
        super.init()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return feet.count
        } else {
            return inches.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(feet[row]) ft"
        } else {
            return "\(inches[row]) in"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedFeet = feet[row]
        } else {
            selectedInches = inches[row]
        }
    }
}

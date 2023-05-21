//
//  PoopDetailViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 12/5/2023.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift

class PoopDetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var poop : Poop?
    var poopIndex : Int?
    let db = Firestore.firestore()
    
    var datePicked: String = ""
    var timePicked: String = ""
    var nappyTypePicked: String = ""
    
    
    @IBOutlet weak var poopNote: UITextField!
    @IBOutlet weak var nappyTypeSegmentPicker: UISegmentedControl!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // customize the format to your liking
        let dateString = dateFormatter.string(from: sender.date)
        datePicked = dateString
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short // Set the time style
        let selectedTime = timeFormatter.string(from: sender.date)
        timePicked = "\(selectedTime)"
    }
    @IBAction func nappyTypeChanged(_ sender: Any) {
        switch nappyTypeSegmentPicker.selectedSegmentIndex {
            case 0:
                nappyTypePicked = "Wet"
                break
            case 1:
                nappyTypePicked = "Wet and Dirty"
                // Second segment selected
                break
            default:
                nappyTypePicked = "Wet"
                break
            }
    }
    
    @IBAction func galleryBtn(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            print("Gallery available")

            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false

            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraBtn(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            print("Camera available")
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            print("No camera available")
        }
    }
    @IBAction func onSave(_ sender: Any) {
        
        (sender as! UIBarButtonItem).title = "Loading..."
        
        let db = Firestore.firestore()
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: datePicker.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timePicked = timeFormatter.string(from: timePicker.date)
        
        switch nappyTypeSegmentPicker.selectedSegmentIndex {
        case 0:
            nappyTypePicked = "Wet"
        case 1:
            nappyTypePicked = "Wet and Dirty"
        default:
            showAlert(message: "Please select a nappy type.")
            return
        }
        
        
        
        poop!.poopDate = dateString
        poop!.poopTime = timePicked
        poop!.poopNote = poopNote.text!
        poop!.nappyType = nappyTypePicked
        
        do
        {
            //update the database (code from lectures)
            try db.collection("poopHistory").document(poop!.documentID!).setData(from: poop!){ err in
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
        let alertController = UIAlertController(title: "Nappy Data Delete", message: "Are you sure you want to delete", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (_) in
                self?.deleteNappyData()
            }))
            
            present(alertController, animated: true, completion: nil)

    }
    
    func deleteNappyData() {
        guard let poopID = poop?.documentID else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("poopHistory").document(poopID).delete { [weak self] error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Growth data deleted successfully")
            
                // Notify the previous view controller to fetch the updated growth data
                if let poopTableViewController = self?.navigationController?.viewControllers.first as? PoopTableViewController {
                    poopTableViewController.fetchPoopsData()
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func onShare(_ sender: Any) {
        let shareViewController = UIActivityViewController(activityItems: [datePicked,timePicked,poopNote.text!,nappyTypePicked], applicationActivities: [])
        shareViewController.popoverPresentationController?.sourceView = (sender as! UIView) // so that iPads won't crash
        shareViewController.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook]
        present(shareViewController, animated: true, completion: nil)
    }
    @IBOutlet weak var poopImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(poop!.poopImage)
        
        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if(error == nil){
                let image = UIImage(data: data!)
                self.poopImage.image = image;
            }
        }
        
        nappyTypeSegmentPicker.selectedSegmentIndex = 0 // Select the first segment by default
        datePicked = getCurrentDate()
        timePicked = getCurrentTime()
        
        if let displayPoop = poop
        {
            
            self.navigationItem.title = displayPoop.poopTime //this awesome line sets the page title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"

            // Get the string value representing the date
            let dateString = displayPoop.poopDate
            // Convert the string to a Date object
            if let date = dateFormatter.date(from: dateString) {
                // Set the date picker's date
                datePicker.date = date
            }
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            timePicker.date = timeFormatter.date(from: displayPoop.poopTime)!
            
            for index in 0..<nappyTypeSegmentPicker.numberOfSegments {
                if let segmentValue = nappyTypeSegmentPicker.titleForSegment(at: index), segmentValue == displayPoop.nappyType {
                    nappyTypeSegmentPicker.selectedSegmentIndex = index
                    break
                }
            }
            
            poopNote.text = displayPoop.poopNote
            
            
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
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            poopImage.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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

}

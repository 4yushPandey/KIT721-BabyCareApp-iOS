//
//  AddPoopViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 14/5/2023.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class AddPoopViewController: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    let db = Firestore.firestore()
    
    var datePicked: String = ""
    var timePicked: String = ""
    var nappyTypePicked: String = ""
    
    @IBOutlet weak var nappyTypeSegmentPicker: UISegmentedControl!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var poopNote: UITextField!
    @IBOutlet weak var poopImage: UIImageView!
    
    
    @IBAction func nappyTypePicker(_ sender: Any) {
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
    @IBAction func imageBtn(_ sender: Any) {
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
        
        
        guard let image = poopImage.image else {
                showAlert(message: "Image is empty")
                return
            }
        // Get a reference to the storage service using the default Firebase App
        let storageRef = Storage.storage().reference()
        // Create a child reference
        // imagesRef now points to "images"
        let imageData = poopImage.image!.jpegData(compressionQuality: 0.5)
        
        guard let uploadData = imageData else {
            print("Error converting image to data")
            return
        }
        let imagePath = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(imagePath)
        
        let uploadTask = fileRef.putData(imageData!) { metadata, error in
            // check error
            if error == nil && metadata != nil{
                print("Image uploaded")
            }
        }
        
        switch nappyTypeSegmentPicker.selectedSegmentIndex {
            case 0:
                nappyTypePicked = "Wet"
                break
            case 1:
                nappyTypePicked = "Wet and Dirty"
                break
            default:
                nappyTypePicked = "Wet"
                break
            }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: datePicker.date)
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let selectedTime = timeFormatter.string(from: timePicker.date)
        
        
        let movieCollection = db.collection("poopHistory")

        let matrix = Poop(nappyType: nappyTypePicked, poopDate: dateString, poopTime: selectedTime, poopImage: imagePath, poopNote: poopNote.text!)
        do {
            print(matrix)
            try movieCollection.addDocument(from: matrix, completion: { [self] (err) in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Successfully created movie")
                    let alertController = UIAlertController(title: "Poop Data Added", message: "Poop Data was successfully added", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                                        self?.navigationController?.popViewController(animated: true)
                                    }))
                    
                    guard let poopTableViewController = navigationController?.viewControllers.first as? PoopTableViewController else {
                        return
                    }
                    poopTableViewController.fetchPoopsData()
                    
                    present(alertController, animated: true, completion: nil)
                }
            })
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nappyTypeSegmentPicker.selectedSegmentIndex = 0 // Select the first segment by default
        datePicked = getCurrentDate()
        timePicked = getCurrentTime()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            poopImage.image = image
            dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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
    
        // Child references can also take paths delimited by '/'
        // spaceRef now points to "images/space.jpg"
        // imagesRef still points to "images"

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



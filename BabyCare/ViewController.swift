//
//  ViewController.swift
//  BabyCare
//
//  Created by Ayush Pandey on 2/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            let db = Firestore.firestore()
            print("\nINITIALIZED FIRESTORE APP \(db.app.name)\n")
        
       
        }
    }



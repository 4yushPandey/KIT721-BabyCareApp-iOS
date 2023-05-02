//
//  Poop.swift
//  BabyCare
//
//  Created by Ayush Pandey on 2/5/2023.
//

import Firebase
import FirebaseFirestoreSwift

public struct Poop : Codable
{
    @DocumentID var documentID:String?
    var nappyType: String
    var poopDate: String
    var poopTime: String
    var poopImage: String
    var poopNote: String
}

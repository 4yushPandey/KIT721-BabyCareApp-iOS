//
//  Sleep.swift
//  BabyCare
//
//  Created by Ayush Pandey on 2/5/2023.
//

import Firebase
import FirebaseFirestoreSwift

public struct Sleep : Codable
{
    @DocumentID var documentID:String?
    var date: String
    var sleepStart: String
    var sleepEnd: String?
    var sleepNote: String?
    var sleepDuration: String?
}

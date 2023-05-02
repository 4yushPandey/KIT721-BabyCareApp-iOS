//
//  Growth.swift
//  BabyCare
//
//  Created by Ayush Pandey on 2/5/2023.
//

import Firebase
import FirebaseFirestoreSwift

public struct Growth : Codable
{
    @DocumentID var documentID:String?
    var height: String
    var measuredDate: String
    var growthNote: String
}

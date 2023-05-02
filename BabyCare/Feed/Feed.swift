//
//  Feed.swift
//  BabyCare
//
//  Created by Ayush Pandey on 2/5/2023.
//

import Firebase
import FirebaseFirestoreSwift

public struct Feed : Codable
{
    @DocumentID var documentID:String?
    var feedDate: String
    var feedStartTime: String
    var milkType: String
    var feedSide: String
    var feedDuration: String
    var quantity: String
    var feedNote: String
}

//
//  Movie.swift
//  BabyCare
//
//  Created by Ayush Pandey on 2/5/2023.
//

import Firebase
import FirebaseFirestoreSwift

public struct Movie : Codable
{
    @DocumentID var documentID:String?
    var title:String
    var year:Int32
    var duration:Float
}

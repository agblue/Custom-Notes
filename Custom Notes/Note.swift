//
//  Note.swift
//  Custom Notes
//
//  Created by Danny Tsang on 7/13/21.
//

import Foundation

class Note: Codable {
    var id:String
    var title: String
    var text: String
    
    init (id:String, title:String, text:String){
        self.id = id
        self.title = title
        self.text = text
    }
    
}

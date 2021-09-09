//
//  Comment.swift
//  networking
//
//  Created by Denys Nikolaichuk on 19.08.2021.
//

import Foundation

class Comment: Codable {
    let postId: Int
    var id: Int
    let name: String
    let email: String
    let body: String
    
    init(id: Int, name: String, email: String, body: String) {
        self.postId = 0
        self.id = id
        self.name = name
        self.email = email
        self.body = body
    }
}

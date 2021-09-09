//
//  Post.swift
//  networking
//
//  Created by Denys Nikolaichuk on 02.08.2021.
//

import Foundation

class Post: Codable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
    
    init(userId: Int, title: String, body: String) {
        self.userId = userId
        self.title = title
        self.body = body
        self.id = 0
    }
}

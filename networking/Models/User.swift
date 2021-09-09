//
//  User.swift
//  networking
//
//  Created by Denys Nikolaichuk on 16.08.2021.
//

import Foundation

class User: Codable {
    var id: Int
    let name: String
    let username: String
    let email: String
    let address: Address?
    let phone: String?
    let website: String?
    let company: Company?
    
    init(id: Int, name: String, username: String, email: String, phone: String, website: String) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.address = Address(street: "", suite: "", city: "", zipcode: "", geo: Geo(lat: "", lng: ""))
        self.phone = phone
        self.website = website
        self.company = Company(name: "", catchPhrase: "", bs: "")
    }
    
    init(entity: UserEntity) {
        self.id = Int(entity.id)
        self.name = entity.name ?? ""
        self.username = entity.userName ?? ""
        self.email = entity.email ?? ""
        self.address = nil
        self.phone = nil
        self.website = nil
        self.company = nil
    }
}

struct Address: Codable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
    
    init(street: String, suite: String, city: String, zipcode: String, geo: Geo) {
        self.street = street
        self.suite = suite
        self.city = city
        self.zipcode = zipcode
        self.geo = geo
    }
}

struct Company: Codable {
    let name: String
    let catchPhrase: String
    let bs: String
    
    
    init(name: String, catchPhrase: String, bs: String) {
        self.name = name
        self.catchPhrase = catchPhrase
        self.bs = bs
    }
}

struct Geo: Codable {
    let lat: String
    let lng: String
  
    init(lat: String, lng: String) {
        self.lat = lat
        self.lng = lng
    }
}

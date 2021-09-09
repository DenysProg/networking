//
//  DataManager.swift
//  networking
//
//  Created by Denys Nikolaichuk on 16.08.2021.
//

import Foundation

class DataManager {
    let coreDataManager = CoreDataManager.shared
    let networkManager = NetworkManager()
    
    func getAllUsers(_ completionHandler: @escaping([User]) -> Void) {
        
        coreDataManager.getAllUsers { users in
            if  users.count > 0 {
                print("From data base")
                completionHandler(users)
            } else {
                self.networkManager.getAll(chooseApi: .users, decodingType: [User].self) { users, error in
                    self.coreDataManager.save(users: users) {
                        completionHandler(users)
                    }
                }
            }
        }
    }
}

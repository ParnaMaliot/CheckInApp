//
//  User.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 11.1.21.
//

import Foundation

typealias UserSaveCompletion = (_ success: Bool,_ error: Error?)-> Void

struct User: Codable {
    var id: String?
    var name: String?
    var password: String?
    var email: String?
    var location: String?
    var latitude: String?
    var longtitude: String?
    var createdAt: TimeInterval?
    
    init(id: String) {
        self.id = id
    }
    
    func save(completion: UserSaveCompletion?) {        
        DataStore.shared.setUserData(user: self) { (sucess, error) in
            completion?(sucess, error)
        }
    }
}

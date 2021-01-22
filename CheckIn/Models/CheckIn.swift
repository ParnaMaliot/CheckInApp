//
//  CheckIn.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 11.1.21.
//

import Foundation
import UIKit

struct CheckIn: Codable {
    var id: String?
    var name: String?
    var imageUrl: String?
    var creatorId: String?
    var createdAt: TimeInterval?
    var location: String?
    var latitude: String?
    var longtitude: String?
}

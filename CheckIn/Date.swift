//
//  Date.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 11.1.21.
//

import Foundation

extension Date {
    public init?(with miliseconds: TimeInterval) {
        self = Date(timeIntervalSince1970: miliseconds / 1000.0)
    }
    
    func toMiliseconds() -> TimeInterval {
        return (self.timeIntervalSince1970 * 1000.0)
    }
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .numeric
        let dateString = formatter.localizedString(for: self, relativeTo: Date())
        if dateString.contains("second") {
            return "just now"
        }
        return dateString
    }
}

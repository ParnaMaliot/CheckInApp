//
//  CheckInCollectionViewCell.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 11.1.21.
//

import UIKit
import Kingfisher
import CoreLocation
import MapKit


class CheckInCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mapView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    var feedItem: CheckIn?
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        //Always when cell does reuse
        nameLabel.text = nil
        latitudeLabel.text = nil
        longitudeLabel.text = nil
        createdAtLabel.text = nil
        locationLabel.text = nil
        mapView.image = nil
    }
    
    func setupCell(feedItem: CheckIn, user: User) {
        self.feedItem = feedItem
        mapView.kf.setImage(with: URL(string: feedItem.imageUrl!))
        setDate(feedItem: feedItem)
        fetchCreatorDetails(user: user, feedItem: feedItem)
    }
    
    func fetchCreatorDetails(user: User, feedItem: CheckIn) {
        guard let userId = user.id else { return }
        DataStore.shared.getUser(uid: userId) { (user, error) in
            if let user = user {
                self.nameLabel.text = "Name: " + "\(String(feedItem.name!))"
                self.latitudeLabel.text = "Latitude: " + "\(String(feedItem.latitude!))"
                self.longitudeLabel.text = "Longitude: " + String(feedItem.longtitude!)
                self.locationLabel.text = "Location: " + String(feedItem.location!)
            }
        }
    }
    
    func setDate(feedItem: CheckIn) {
        guard let time = feedItem.createdAt else {return}
        let date = Date(with: time)
        createdAtLabel.text = date?.timeAgoDisplay()
    }
}

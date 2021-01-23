//
//  FullImageViewController.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 17.1.21.
//

import UIKit
import Kingfisher

class FullImageViewController: UIViewController {
    
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longtitude: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    
    var image: UIImage?
    var created = TimeInterval()
    var transfer = CheckIn()
    var userName = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapImage.image = image
        name.text = "Name: " + userName
        location.text = "Location: " + transfer.location!
        latitude.text = "Latitude: " + transfer.latitude!
        longtitude.text = "Longitude: " + transfer.longtitude!
        setDate(feedItem: transfer)    }
    
    func setDate(feedItem: CheckIn) {
        guard let time = transfer.createdAt else {return}
        let date = Date(with: time)
        createdAt.text = date?.timeAgoDisplay()
    }

    
}

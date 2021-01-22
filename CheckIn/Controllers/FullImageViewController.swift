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
    var loc = ""
    var long = ""
    var lat = ""
    var created = TimeInterval()
   // var user = ""
    var test = ""

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapImage.image = image
        name.text = test
        location.text = "Location: " + "\(loc)"
        latitude.text = "Latitude: " + "\(lat)"
        longtitude.text = "Longitude: " + "\(long)"
        createdAt.text = "\(created)"
    }
}

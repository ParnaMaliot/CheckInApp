//
//  HomeViewController.swift
//  CheckIn
//
//  Created by Igor Parnadziev on 11.1.21.
//

import UIKit
import SVProgressHUD
import CoreLocation
import MapKit
import Kingfisher


class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noChecksInLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControll = UIRefreshControl()
    var checkIn = [CheckIn]()
    var pickedImage: UIImage?
    let locationManager = CLLocationManager()
    var moment = CheckIn()
    var filterCheckIns = [CheckIn]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterCheckIns.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CheckInCollectionViewCell", for: indexPath) as! CheckInCollectionViewCell
        let displayedCell = filterCheckIns[indexPath.row]
        guard let user = DataStore.shared.localUser else {return cell}
        cell.setupCell(feedItem: displayedCell, user: user)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchFeedItems()
        refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("ReloadFeedAfterUserAction"), object: nil)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        mapView.isHidden = true
        registerForKeyboardNotifications()
        searchBar.delegate = self
    }
    
    func setupCollectionView() {
        refreshControll.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControll
        
        collectionView.register(UINib(nibName: "CheckInCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CheckInCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: collectionView.frame.width, height: 200)
            layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 375)
        }
    }
    
    @objc func refresh() {
        fetchFeedItems()
    }
    
    private func fetchFeedItems() {
        SVProgressHUD.show()
        DataStore.shared.fetchFeedItems { (feeds, error) in
            SVProgressHUD.dismiss()
            self.refreshControll.endRefreshing()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let feeds = feeds {
                self.checkIn = feeds
                if feeds.count == 0 {
                    self.noChecksInLabel.isHidden = false
                } else {
                    self.noChecksInLabel.isHidden = true
                }
                self.sortAndReload()
            }
        }
    }
    
    private func sortAndReload() {
        self.checkIn.sort { (feedOne, feedTwo) -> Bool in
            guard let oneDate = feedOne.createdAt else { return false }
            guard let twoDate = feedTwo.createdAt else { return false }
            return oneDate > twoDate
        }
        self.filterCheckIns = self.checkIn
       // reloadFeedNotification(feedItem: moment)
        collectionView.reloadData()
    }
    
    func reloadFeedNotification(feedItem: CheckIn) {
        //guard let localUser = DataStore.shared.localUser, let usersId = localUser.id else { return }
        DataStore.shared.getAllUsers { (users, error) in
            if let users = users {
                for user in users {
                    self.filterCheckIns = self.filterCheckIns.filter({$0.creatorId == user.id})
            }
            }
            self.collectionView.reloadData()
        }
        //guard let creatorId = moment.creatorId else { return }
        //filterCheckIns = filterCheckIns.filter({$0.creatorId == usersId})
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.002,longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: coordinations, span: span)
        mapView.setRegion(region, animated: false)
        mapView.mapType = .standard
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                self.moment.location = "\(placemark.name!), \(placemark.administrativeArea!), \(placemark.country!)"
                self.moment.latitude = "\(coordinations.latitude)"
                self.moment.longtitude = "\(coordinations.longitude)"
                //self.moment.name =
            }
        }
        let options = MKMapSnapshotter.Options()
        options.region = mapView.region
        options.size = mapView.frame.size
        options.scale = UIScreen.main.scale
        let rect = collectionView.bounds
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                print("Snapshot error: \(error!.localizedDescription)")
                return
            }
            let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                snapshot.image.draw(at: .zero)
                let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                let pinImage = pinView.image
                var point = snapshot.point(for: userLocation.coordinate)
                if rect.contains(point) {
                    point.x -= pinView.bounds.width / 2
                    point.y -= pinView.bounds.height / 10
                    point.x += pinView.centerOffset.x
                    point.y += pinView.centerOffset.y
                    pinImage?.draw(at: point)
                }
            }
            self.pickedImage = image
        }
    }

    
    @IBAction func takeLocation(_ sender: UIButton) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true

        guard var localUser = DataStore.shared.localUser else {
            return
        }
        guard let pickedImage = pickedImage else {
            return
        }
        SVProgressHUD.show()
        let uuid = UUID().uuidString
        DataStore.shared.uploadImage(image: pickedImage, itemId: uuid, isUserImage: false) { (url, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                print(error.localizedDescription)
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let url = url {
                self.moment.imageUrl = url.absoluteString
                DataStore.shared.createFeedItem(item: self.moment) { (feed, error) in
                    SVProgressHUD.dismiss()
                    if let error = error {
                        self.showErrorWith(title: "Error", msg: error.localizedDescription)
                        return
                    }
                }
                return
            }
            SVProgressHUD.dismiss()
        }
        localUser.save { (_, _) in
            localUser.id = self.moment.creatorId
            localUser.name = self.moment.name
            self.moment.createdAt = Date().toMiliseconds()
            localUser.location = self.moment.location
            localUser.latitude = self.moment.latitude
            localUser.longtitude = self.moment.longtitude
        }
        
        moment.name = localUser.name
        moment.creatorId = localUser.id
        self.checkIn.append(self.moment)

    }
    
    @IBAction func checkInButton(_ sender: UIButton) {
        fetchFeedItems()
        sortAndReload()
        refresh()
        
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fetchFeedItems()
        let image = checkIn[indexPath.row]
        var transfredImage: UIImage?
        
        func downloadImage(with urlString : String){
            guard let url = URL.init(string: image.imageUrl!) else {
                return
            }
            let resource = ImageResource(downloadURL: url)

            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    transfredImage = value.image
                    print("Image: \(value.image). Got from: \(value.cacheType)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        downloadImage(with: image.imageUrl!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        fetchFeedItems()
        controller.transfer = image
        controller.userName = image.name ?? "test"
        controller.image = transfredImage
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filterCheckIns.removeAll()
            filterCheckIns.append(contentsOf: checkIn)
            collectionView.reloadData()
            return
        }
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        filterCheckIns = checkIn.filter({($0.name?.lowercased().contains(text.lowercased()) ?? false)})
        collectionView.reloadData()
    }



    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardDidShow(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)

            }
        }
    }

    @objc func keyboardDidHide(notification: Notification) {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}


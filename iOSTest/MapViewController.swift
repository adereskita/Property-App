//
//  MapViewController.swift
//  iOSTest
//
//  Created by Ade Reskita on 09/08/20.
//  Copyright © 2020 Ade Reskita. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailViewHeight: NSLayoutConstraint!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var alamatLbl: UILabel!
    @IBOutlet weak var imageViewMap: UIImageView!
    @IBOutlet weak var detailBtn: UIButton!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: CLLocationDistance = 1500
    
    var annotations = [MKPointAnnotation]()
    var posts = [PostAnnotation]()
    
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
        locationManager.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backBtnPressed))
        backBtn.addGestureRecognizer(tap)
        let taps: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailBtnPressed))
        detailBtn.addGestureRecognizer(taps)
        
        dataFetch()
//        self.mapView.showAnnotations(annotations, animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.detailView.isHidden = true
    }
    
    @objc func backBtnPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func detailBtnPressed(){
        let storyboard: UIStoryboard = UIStoryboard(name: "DetailProperty", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "detailproperty") as! DetailPropertyViewController
        
        vc.id = self.id
        present(vc, animated: true, completion: nil)

    }

    func dataFetch(){
            let url = "https://api.jsonbin.io/b/5e1552c35df6407208319336/1"

            AF.request(url,
            method: .get,
    //        parameters: headers,
            encoding: JSONEncoding.default,
            headers: APIManager.headers()).responseJSON { response in

                switch response.result {
                case let .success(value):
                    
                    let json = JSON(value)
                    
                    for i in 0 ..< json["data"]["list"].count{
                        let id = json["data"]["list"][i]["id"].string!
                        let title = json["data"]["list"][i]["title"].string!
                        let imageurl = json["data"]["list"][i]["image"].string!
                        let pricetag = json["data"]["list"][i]["attribute"]["price"].string!
                        let alamat = json["data"]["list"][i]["location"]["address"].string!
                        let lat = json["data"]["list"][i]["location"]["latitude"].string!
                        let long = json["data"]["list"][i]["location"]["longitude"].string!
                        
                        let lats = Double(lat)
                        let longs = Double(long)
                        
                        let location = CLLocationCoordinate2DMake(lats!, longs!)
                        self.posts.append(
                            PostAnnotation(id: id, title: title, imageurl: imageurl,
                                           priceTag: pricetag, alamat: alamat, coordinate: location))
                        
                        self.setAnnotation(index: i, lat: lats!, long: longs!, title: title, address: alamat)
                        
                    }
                    
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }// end of response
        }
    
    func setAnnotation(index:Int ,lat:Double, long:Double, title:String, address:String){
        let annotation = Annotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.index = index
        annotation.title = title
        annotation.subtitle = address
        annotations.append(annotation)
        
        self.mapView.addAnnotations(annotations)
//        self.mapView.addAnnotation(annotation)

        //if i wanted to go to specific view
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        mapView.setRegion(region, animated: true)
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func configureLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                    break
                case .restricted, .denied:
                    
                    let alert = UIAlertController(title: "Allow Location Access", message: "App needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)

                    // Button to Open Settings
                    alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)")
                            })
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    print("Access")
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
        }
        
//        if authorizationStatus == .notDetermined {
//            locationManager.requestWhenInUseAuthorization()
//        } else {
//            locationManager.requestLocation()
//            return
//        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }

    //  MARK: - MapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("viewForAnnotation \(annotation.title)")
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = false
        }
        return pinView
    }
    
    // somthin that would great to implement
    //https://sweettutos.com/2016/03/16/how-to-completely-customise-your-map-annotations-callout-views/

    //https://stackoverflow.com/questions/42144195/how-to-get-property-data-from-annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        self.detailView.isHidden = false
                
        if let annotation = view.annotation as? Annotation  {
            let post = posts[annotation.index]

            self.id = post.id!
            self.imageViewMap.image = UIImage(url: URL(string: post.imageurl!))
            
            let numb = (post.priceTag! as NSString).integerValue
            let formater = NumberFormatter()
            formater.groupingSeparator = "."
            formater.numberStyle = .decimal
            let formattedNumber = formater.string(for: numb)
            
            self.priceLbl.text = "Rp " + formattedNumber!
            self.titleLbl.text = post.title
            self.alamatLbl.text = post.alamat
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.detailView.isHidden = true
    }

}

//
//  DetailPropertyViewController.swift
//  iOSTest
//
//  Created by Ade Reskita on 08/08/20.
//  Copyright © 2020 Ade Reskita. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DetailPropertyViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var tanahLbl: UILabel!
    @IBOutlet weak var bangunanLbl: UILabel!
    @IBOutlet weak var deskripsiLbl: UILabel!
    @IBOutlet weak var lantaiLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var fasilitasLbl: UILabel!
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var namaLbl: UILabel!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var bathroomLbl: UILabel!
    @IBOutlet weak var bedroomLbl: UILabel!
    @IBOutlet weak var userTypeLbl: UILabel!

    var id:String = ""
    var propertyData = [Property]()

    var initialInteractivePopGestureRecognizerDelegate: UIGestureRecognizerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        self.showSpinner(onView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataFetch()
    }
    
    @IBAction func CallAgent(_ sender: Any) {
        guard let number = URL(string: "tel://" + "085156681548") else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)

    }
    
    @IBAction func shareDetail(_ sender: Any) {
        let text = self.titleLbl.text

        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes =
            [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
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
                        if json["data"]["list"][i]["id"].string! == self.id {
                            let id = json["data"]["list"][i]["id"].string!
                            let title = json["data"]["list"][i]["title"].string!
                            let imageurl = json["data"]["list"][i]["image"].string!
                            let pricetag = json["data"]["list"][i]["attribute"]["price"].string!
                            let alamat = json["data"]["list"][i]["location"]["address"].string!
                            let description = json["data"]["list"][i]["description"].string!
                            let land_size = json["data"]["list"][i]["attribute"]["land_size"].string!
                            let building_size = json["data"]["list"][i]["attribute"]["building_size"].string!
                            let bedrooms = json["data"]["list"][i]["attribute"]["bedrooms"].string!
                            let bathrooms = json["data"]["list"][i]["attribute"]["bathrooms"].string!
                            let floor = json["data"]["list"][i]["attribute"]["floor"].string!
                            let fasilities = json["data"]["list"][i]["fasilities"].string!
                            let type = json["data"]["list"][i]["type"].string!
                            let nama = json["data"]["list"][i]["agent"]["name"].string!
                            let avatarUrl = json["data"]["list"][i]["agent"]["photo"].string!
                            let userType = json["data"]["list"][i]["agent"]["type"].string!
                            
                            let numb = (pricetag as NSString).integerValue
                            
                            let formater = NumberFormatter()
                            formater.groupingSeparator = "."
                            formater.numberStyle = .decimal
                            let formattedNumber = formater.string(for: numb)
                            self.priceLbl.text = "Rp " + formattedNumber!

                            self.titleLbl.text = title
                            self.addressLbl.text = alamat
                            self.tanahLbl.text = "Luas Tanah: " + land_size + " m²"
                            self.bangunanLbl.text = "Luas Bangunan: " + building_size + " m²"
                            self.deskripsiLbl.text = description
                            self.namaLbl.text = nama
                            self.fasilitasLbl.text = fasilities
                            self.idLbl.text = id
                            self.typeLbl.text = type
                            self.lantaiLbl.text = floor
                            self.bedroomLbl.text = bedrooms
                            self.bathroomLbl.text = bathrooms
                            self.userTypeLbl.text = userType
                            
                            self.imageView.image = UIImage(url: URL(string: imageurl))
                            
                            self.imageAvatar.image = UIImage(url: URL(string: avatarUrl))
                            self.imageAvatar.layer.borderWidth = 1.0
                            self.imageAvatar.layer.masksToBounds = false
                            self.imageAvatar.layer.borderColor = UIColor.white.cgColor
                            self.imageAvatar.layer.cornerRadius = self.imageAvatar.frame.size.width / 2
                            self.imageAvatar.clipsToBounds = true
                            
                        }
                    }
                    self.removeSpinner()
                    
                case let .failure(error):
                    print(error.localizedDescription)
                }
        }// end of response
    }
}

extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}

var vSpinner : UIView? // global var

extension DetailPropertyViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

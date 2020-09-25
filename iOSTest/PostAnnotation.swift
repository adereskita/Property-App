//
//  PostAnnotation.swift
//  iOSTest
//
//  Created by Ade Reskita on 09/08/20.
//  Copyright © 2020 Ade Reskita. All rights reserved.
//

import UIKit
import MapKit

class PostAnnotation: NSObject, MKAnnotation {
    
    var id: String?
    var title: String?
    var imageurl: String?
    var priceTag: String?
    var alamat: String?
    var coordinate: CLLocationCoordinate2D

    init(id : String ,title : String , imageurl : String , priceTag : String , alamat : String ,
         coordinate : CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.imageurl = imageurl
        self.priceTag = priceTag
        self.alamat = alamat
        self.coordinate = coordinate
    }

}

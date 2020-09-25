//
//  Property.swift
//  iOSTest
//
//  Created by Ade Reskita on 07/08/20.
//  Copyright © 2020 Ade Reskita. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class Property: NSObject {

    var id : String
    var title : String
    var imageUrl : String
    var priceTag : String
    var desc : String
    var alamat : String
    var fasilities : String
    var tanah : String
    var bangunan : String
    
    init(_ id:String, _ title:String, _ imageUrl:String, _ priceTag:String, _ desc:String, _ alamat:String,
         _ bangunan:String, _ tanah:String, _ fasilities:String){
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.priceTag = priceTag
        self.desc = desc
        self.alamat = alamat
        self.fasilities = fasilities
        self.tanah = tanah
        self.bangunan = bangunan
    }
}

class realmProperty : Object {
    @objc dynamic var isLiked = false
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var imageUrl = ""
    @objc dynamic var priceTag = ""
    @objc dynamic var desc = ""
    @objc dynamic var alamat = ""
    @objc dynamic var fasilities = ""
    @objc dynamic var tanah = ""
    @objc dynamic var bangunan = ""
    
    override class func primaryKey() -> String? {
        return "title"
    }
}

//
//  TableViewCell.swift
//  iOSTest
//
//  Created by Ade Reskita on 07/08/20.
//  Copyright © 2020 Ade Reskita. All rights reserved.
//

import UIKit
import RealmSwift

protocol TableViewCellDelegate {
    func didTapLike(cell: TableViewCell)
}

class TableViewCell: UITableViewCell {
    
    static let identifier = "TableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "TableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var priceTagLabel: UILabel!
    @IBOutlet weak var tanahLbl: UILabel!
    @IBOutlet weak var bangunanLbl: UILabel!
    @IBOutlet weak var alamatLabel: UILabel!
    @IBOutlet weak var kontakButton: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    
    var isLoved = false
    
    var propertyLike: Results<realmProperty>!
    var property: Property!
    var realmProp: realmProperty?
    var indexPath:IndexPath?
    
    var viewController = ViewController()
    var delegate: TableViewCellDelegate?
    
    let realm = try! Realm()
    let properties = realmProperty()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        kontakButton.layer.cornerRadius = 10
        kontakButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    @IBAction func starPressed(_ sender: Any) {
        self.delegate?.didTapLike(cell: self)
    }
    
    func setData(_ property:Property){
        self.property = property
        
        if property.priceTag.count >= 6 && property.priceTag.count <= 9 {
            priceTagLabel.text = "Rp." + property.priceTag.dropLast(6) + "Jt"
        }else if property.priceTag.count > 9 {
            priceTagLabel.text = "Rp." + property.priceTag.dropLast(9) + "M"
        }else {
            priceTagLabel.text = "Rp." + property.priceTag
        }
        titleLbl.text = property.title
        tanahLbl.text = "Luas Tanah: " + property.tanah + " m²"
        bangunanLbl.text = "Luas Bangunan: " + property.bangunan + " m²"
        alamatLabel.text = property.alamat
        
        if #available(iOS 13.0, *) {
            starBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
        starBtn.tintColor = .black
        isLoved = false
        
        //set image
        guard let imageURL = URL(string: property.imageUrl) else { return }
        // just to not cause a deadlock in UI
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.imageViewCell.image = image
            }
        }
    }
    
    func setDataRealm(_ property:realmProperty){
        self.realmProp = property
        
        if property.priceTag.count >= 6 && property.priceTag.count <= 9 {
            priceTagLabel.text = "Rp." + property.priceTag.dropLast(6) + "Jt"
        }else if property.priceTag.count > 9 {
            priceTagLabel.text = "Rp." + property.priceTag.dropLast(9) + "M"
        }else {
            priceTagLabel.text = "Rp." + property.priceTag
        }
        titleLbl.text = property.title
        tanahLbl.text = "Luas Tanah: " + property.tanah + " m²"
        bangunanLbl.text = "Luas Bangunan: " + property.bangunan + " m²"
        alamatLabel.text = property.alamat
        
        if property.isLiked {
            isLoved = true
            if #available(iOS 13.0, *) {
                starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                starBtn.tintColor = .yellow
            }
        }
        
        //set image
        guard let imageURL = URL(string: property.imageUrl) else { return }
        // just to not cause a deadlock in UI
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.imageViewCell.image = image
            }
        }
        
    }
    
}

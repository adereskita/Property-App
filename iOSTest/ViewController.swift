//
//  ViewController.swift
//  iOSTest
//
//  Created by Ade Reskita on 07/08/20.
//  Copyright © 2020 Ade Reskita. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var notificationToken: NotificationToken? = nil
    
    var propertyLike: Results<realmProperty>!
    var realm = try! Realm()
    
    var propertyData = [Property]()
    var searchTitle = [realmProperty]()
    var isSearching = false
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//         Do any additional setup after loading the view.
        self.tableView.register(TableViewCell.nib(), forCellReuseIdentifier: TableViewCell.identifier)
        
        self.showSpinner(onView: self.view)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchBar.delegate = self
        
        propertyLike = realm.objects(realmProperty.self) //gets all property from realm
        dataFetch()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
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
                    let description = json["data"]["list"][i]["description"].string!
                    let land_size = json["data"]["list"][i]["attribute"]["land_size"].string!
                    let building_size = json["data"]["list"][i]["attribute"]["building_size"].string!
                    let fasilities = json["data"]["list"][i]["fasilities"].string!
                    self.propertyData.append(Property(id, title, imageurl, pricetag, description, alamat, building_size, land_size, fasilities))
                }
                
                self.tableView.reloadData()
                
                print(value)
                self.removeSpinner()
            case let .failure(error):
                print(error.localizedDescription)
            }
        }// end of response
    }
}

//  MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return searchTitle.count
        } else {
            return propertyData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let property = propertyData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as! TableViewCell
//        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
    
        cell.delegate = self
        
        if isSearching {
            let searchProp = searchTitle[indexPath.row]
            //offline
            cell.setDataRealm(searchProp)
        } else {
            //api
            cell.setData(property)
        }
            
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = storyboard.instantiateInitialViewController()!
        let storyboard: UIStoryboard = UIStoryboard(name: "DetailProperty", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "detailproperty") as! DetailPropertyViewController
        
        let property = propertyData[indexPath.row]
        vc.id = property.id
        
        if isSearching {
            tableView.deselectRow(at: indexPath, animated: true)
        }else {
            navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
//        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 480
    }
}

//  MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == "" {
            isSearching = false
            self.tableView.reloadData()
        } else {
            //search offline data
            searchTitle = propertyLike.filter({$0.title.lowercased().range(of: searchText.lowercased()) != nil})
            isSearching = true
            self.tableView.reloadData()
            //load data
//            propertyLike = realm.objects(realmProperty.self).sorted(byKeyPath: "id", ascending: true)

        }
    }
}

//  MARK: - TableViewCellDelegate Protocol
extension ViewController: TableViewCellDelegate {
    //https://stackoverflow.com/questions/39585638/get-indexpath-of-uitableviewcell-on-click-of-button-from-cell/39585749
    func didTapLike(cell: TableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        print(indexPath!.row)
    
        
        if cell.isLoved == false {
            cell.isLoved = true
        }else {
            cell.isLoved = false
        }
        
        if #available(iOS 13.0, *) {
            if cell.isLoved {
                cell.starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                cell.starBtn.tintColor = .yellow
                
                cell.properties.id = cell.property.id
                cell.properties.isLiked = true
                cell.properties.title = cell.property.title
                cell.properties.alamat = cell.property.alamat
                cell.properties.imageUrl = cell.property.imageUrl
                cell.properties.priceTag = cell.property.priceTag
                cell.properties.tanah = cell.property.tanah
                cell.properties.bangunan = cell.property.bangunan
                try! realm.write {
                    print("realm created")
                    realm.add(cell.properties, update: .all)
                }
            } else {
                cell.starBtn.setImage(UIImage(systemName: "star"), for: .normal)
                cell.starBtn.tintColor = .black
                try! realm.write {
                    print("realm deleted")
                    realm.delete(propertyLike[indexPath!.row])
                }
//                notificationToken = propertyLike.observe { [weak self] (changes: RealmCollectionChange) in
//                    guard let tableView = self?.tableView else { return }
//                    switch changes {
//                    case .initial:
//                        tableView.reloadData() //this is when the realm data is intially loaded.
//                    case .update(_, let deletions, let insertions, let modifications):
//                        self?.tableView.beginUpdates()
//                        self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
//                                             with: .automatic)
//
//                        self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
//                                             with: .automatic)
//                        self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
//                                             with: .automatic)
//                        self?.tableView.endUpdates()
//                    case .error(let error):
//                        fatalError("\(error)")
//                    }
//                }
            }
        } else {
            //Fallback on earlier versions
        }
    }
}

extension ViewController {
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



//
//  NavigationBarView.swift
//  iOSTest
//
//  Created by Ade Reskita on 09/08/20.
//  Copyright © 2020 Ade Reskita. All rights reserved.
//

import Foundation
import UIKit

class NavigationBarView: UIView {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var starBtn: UIButton!
    
   private static let NIB_NAME = "NavigationBar"
        
        var isLeftButtonHidden: Bool {
            set {
                backBtn.isHidden = newValue
            }
            get {
                return backBtn.isHidden
            }
        }
        
        var isRightFirstButtonEnabled: Bool {
            set {
                starBtn.isEnabled = newValue
            }
            get {
                return starBtn.isEnabled
            }
        }
        
        override func awakeFromNib() {
            initWithNib()
        }
        
        private func initWithNib() {
            Bundle.main.loadNibNamed(NavigationBarView.NIB_NAME, owner: self, options: nil)
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            setupLayout()
        }
        
        private func setupLayout() {
            NSLayoutConstraint.activate(
                [
                    view.topAnchor.constraint(equalTo: topAnchor),
                    view.leadingAnchor.constraint(equalTo: leadingAnchor),
                    view.bottomAnchor.constraint(equalTo: bottomAnchor),
                    view.trailingAnchor.constraint(equalTo: trailingAnchor),
                ]
            )
        }
}

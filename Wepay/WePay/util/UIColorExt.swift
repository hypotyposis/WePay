//
//  UIColorExt.swift
//  WePay
//
//  Created by Wallance on 2019/7/10.
//  Copyright © 2019 Wallance. All rights reserved.
//

import Foundation
import UIKit
extension UIColor {
    class var randomColor: UIColor {
            get {
                let red = CGFloat(arc4random()%256)/255.0
                let green = CGFloat(arc4random()%256)/255.0
                let blue = CGFloat(arc4random()%256)/255.0
                return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            }
    }
}


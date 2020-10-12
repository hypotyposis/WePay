//
//  GetOrderModel.swift
//  WePay
//
//  Created by Wallance on 2019/7/16.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
class GetOrderModel{
    
    
    var id: Int
    var statusStr: String
    var payment: Double
    var paymentType: String
    var items: [ItemModel]
    init?(id: Int, statusStr: String, payment: Double, paymentType: String,items: [ItemModel]) {
        self.id = id
        self.items = items
        self.payment = payment
        self.paymentType = paymentType
        self.statusStr = statusStr
    }
}

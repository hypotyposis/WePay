//
//  OrderModel.swift
//  WePay
//
//  Created by Wallance on 2019/7/16.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
class OrderModel{
    

    var itemIds :[Int]
    var payment: Double
    var paymentType: String
    var sellerId : Int
    init?(itemIds :[Int], payment: Double, paymentType: String, sellerId : Int) {
        self.itemIds = itemIds
        self.payment = payment
        self.paymentType = paymentType
        self.sellerId = sellerId
    }
}

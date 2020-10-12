//
//  PaymentModel.swift
//  WePay
//
//  Created by Wallance on 2019/7/15.
//  Copyright © 2019 Wallance. All rights reserved.
//
import UIKit
class PaymentModel{
    
    
    var bizId :String
    var name: String
    var paymentType: Int
    var amount: Double
    var id:Int
    init?(bizId :String, name: String, paymentType: Int, amount: Double,id:Int) {
        self.bizId = bizId
        self.name = name
        self.paymentType = paymentType
        self.amount = amount
        self.id = id
    }
}

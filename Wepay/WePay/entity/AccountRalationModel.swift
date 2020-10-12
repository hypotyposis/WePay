//
//  AccountRalationModel.swift
//  WePay
//
//  Created by Wallance on 2019/7/10.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
class AccountRelationModel{
    
    var id: Int
    var ralationName: String
    var monthLimit: Double
    var singleLimit: Double
    var ralationID: Int
    init?(id:Int, ralationName:String, monthLimit:Double, singleLimit:Double,ralationID:Int) {
        self.id = id
        self.ralationName = ralationName
        self.monthLimit = monthLimit
        self.singleLimit = singleLimit
        self.ralationID = ralationID
    }
}

//
//  ItemModel.swift
//  WePay
//
//  Created by Wallance on 2019/7/16.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
class ItemModel{
    var id : Int
    var title: String
    var cover: String
    var catalog: String
    var price: Double
    init?(id : Int, title: String, cover: String, catalog: String, price: Double) {
        self.catalog = catalog
        self.cover = cover
        self.id = id
        self.price = price
        self.title = title
    }
}

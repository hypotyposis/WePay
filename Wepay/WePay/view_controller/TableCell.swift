//
//  TableCell.swift
//  WePay
//
//  Created by Wallance on 2019/7/16.
//  Copyright © 2019 Wallance. All rights reserved.
//
import UIKit

class Cell: UITableViewCell {
    //MARK: properties
    @IBOutlet weak var ralationName: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var monthLimit: UILabel!
    @IBOutlet weak var singleLimit: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

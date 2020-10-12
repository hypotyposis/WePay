//
//  DetailCell.swift
//  WePay
//
//  Created by Wallance on 2019/7/17.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {
    //MARK: properties

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var ralationName: UILabel!
    @IBOutlet weak var Price: UILabel!
    @IBOutlet weak var Catelog: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

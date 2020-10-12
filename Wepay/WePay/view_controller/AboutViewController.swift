//
//  AboutViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/9.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let  subview = UIView(frame: view.frame)
        let layer = CAGradientLayer()
        layer.frame = subview.bounds
        layer.colors = [UIColor.white.cgColor,UIColor.white.cgColor]
        layer.locations = [0,1]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 2, y: 0)
        subview.layer.addSublayer(layer)
        self.view.insertSubview(subview, belowSubview: contentView)
        
        if let revealVC = revealViewController(){
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

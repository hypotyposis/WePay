//
//  NewsDetailViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/17.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {

    @IBOutlet weak var naviBar: UINavigationBar!
    var order : GetOrderModel = GetOrderModel(id: 0, statusStr: "", payment: 0, paymentType: "", items: [])!
    
    @IBOutlet weak var accountTableView: UITableView!
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
        view.insertSubview(subview, belowSubview: contentView)
        
        naviBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        naviBar.shadowImage = UIImage()
        
        accountTableView.backgroundColor = UIColor.clear
        accountTableView.dataSource = self
        accountTableView.delegate = self
        accountTableView.rowHeight = 63
        accountTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
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
extension NewsDetailViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  order.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DetailCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        cell.backgroundColor = UIColor.clear
        
        let item = order.items[indexPath.row]
        cell.Catelog.text = item.catalog
        cell.ralationName.text = item.title
        cell.Price.text = String(item.price)
        let url = URL(string: item.cover)
        do{
            let data = try Data(contentsOf: url!)
            cell.coverImage.image = UIImage(data: data)?.toCircle()
        }catch let error as NSError{
            print(error)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "Detail"
//    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//    }
}

//
//  NewsViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/9.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewsViewController: UIViewController {
    @IBOutlet weak var accountTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    
    var orders = [GetOrderModel]()
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
        if let revealVC = revealViewController(){
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        accountTableView.backgroundColor = UIColor.clear
        accountTableView.dataSource = self
        accountTableView.delegate = self
        accountTableView.rowHeight = 50
        accountTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        loadOrders()
    }
    
    private func loadOrders(){
        
        let urlString = "http://101.132.185.90:5418/order/queryOrders?status=1"
        let headers:HTTPHeaders = ["token": ((UserDefaults.standard.object(forKey: "token") as? String)!)]
        ViewController.sharedSessionManager.request(urlString, method: .get,  encoding: JSONEncoding.default,headers: headers)
            .responseJSON{
                response in
//                debugPrint(response)
                if response.result.isSuccess{
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["code"].int == 401 {
                            let alertController = UIAlertController(title: "No token,please Log in",
                                                                    message: nil, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                action in
                                self.performSegue(withIdentifier: "backToRoot", sender: nil)
                            } )
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }else if json["code"].int == 200{
                            let list = json["data"]["result"].array!
                            //                            let num = json["data"]["size"].int!
                            for item in list{
                                var itemModels = [ItemModel]()
                                let items = item["items"].array!
                                for eachitem in items{
                                    let eachItemModel = ItemModel(id: eachitem["id"].int ?? 0, title: eachitem["title"].string ?? "", cover: eachitem["cover"].string ?? "", catalog: eachitem["catalog"].string ?? "", price: eachitem["price"].double ?? 0)
                                    itemModels += [eachItemModel!]
                                }
                                let order = GetOrderModel(id: item["id"].int!, statusStr: item["statusStr"].string!, payment: item["payment"].double!, paymentType: item["paymentType"].string!, items: itemModels)
                                self.orders += [order!]
                            }
                            self.accountTableView.reloadData()
                            
                        }else{
                            let alertController = UIAlertController(title: "Fail to Load",
                                                                    message:json["message"].string, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
        }
        let urlString2 = "http://101.132.185.90:5418/order/queryOrders?status=6"
        ViewController.sharedSessionManager.request(urlString2, method: .get,  encoding: JSONEncoding.default,headers: headers)
            .responseJSON{
                response in
//                debugPrint(response)
                if response.result.isSuccess{
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["code"].int == 401 {
                            let alertController = UIAlertController(title: "No token,please Log in",
                                                                    message: nil, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                action in
                                self.performSegue(withIdentifier: "backToRoot", sender: nil)
                            } )
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }else if json["code"].int == 200{
                            let list = json["data"]["result"].array!
                            //                            let num = json["data"]["size"].int!
                            for item in list{
                                var itemModels = [ItemModel]()
                                let items = item["items"].array!
                                for eachitem in items{
                                    let eachItemModel = ItemModel(id: eachitem["id"].int ?? 0, title: eachitem["title"].string ?? "", cover: eachitem["cover"].string ?? "", catalog: eachitem["catalog"].string ?? "", price: eachitem["price"].double ?? 0)
                                    itemModels += [eachItemModel!]
                                }
                                let order = GetOrderModel(id: item["id"].int!, statusStr: item["statusStr"].string!, payment: item["payment"].double!, paymentType: item["paymentType"].string!, items: itemModels)
                                self.orders += [order!]
                            }
                            self.accountTableView.reloadData()
                            
                        }else{
                            let alertController = UIAlertController(title: "Fail to Load",
                                                                    message:json["message"].string, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
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
extension NewsViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        cell.backgroundColor = UIColor.clear
        cell.ralationName.font=UIFont.systemFont(ofSize: 13)
        cell.id.font=UIFont.systemFont(ofSize: 13)
        cell.monthLimit.font=UIFont.systemFont(ofSize: 13)
        cell.singleLimit.font=UIFont.systemFont(ofSize: 13)
        if(indexPath.row == 0){
            cell.ralationName.font=UIFont.boldSystemFont(ofSize: 13)
            cell.id.font=UIFont.boldSystemFont(ofSize: 13)
            cell.monthLimit.font=UIFont.boldSystemFont(ofSize: 13)
            cell.singleLimit.font=UIFont.boldSystemFont(ofSize: 13)
            cell.ralationName.text = "类型"
            cell.id.text = "付款"
            cell.monthLimit.text = "状态"
            cell.singleLimit.text = "标号"
        }else{
            cell.ralationName.font=UIFont.systemFont(ofSize: 12)
            cell.id.font=UIFont.systemFont(ofSize: 12)
            cell.monthLimit.font=UIFont.systemFont(ofSize: 12)
            cell.singleLimit.font=UIFont.systemFont(ofSize: 12)
            let order = orders[indexPath.row-1]
//            if order.statusStr != "待确认"{
//                cell.selectionStyle = UITableViewCell.SelectionStyle.none
//            }
            cell.ralationName.text = order.paymentType
            cell.id.text = String(order.payment)
            cell.monthLimit.text = order.statusStr
            cell.singleLimit.text = String(order.id)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? Cell
        let order = orders[indexPath.row-1]
        if cell?.monthLimit.text != "待确认"{
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
            let alertController = UIAlertController(title: "Confirm Order?",
                                                    message:nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
            let confrimAction = UIAlertAction(title:"Confirm",style: .default,handler: {
                action in
                let para:Parameters = ["id": order.id,
                                       "operator": 0]
                let urlString = "http://101.132.185.90:5418/order/confirm"
                let headers:HTTPHeaders = ["token": ((UserDefaults.standard.object(forKey: "token") as? String)!)]
                ViewController.sharedSessionManager.request(urlString, method: .post,parameters: para,  encoding: JSONEncoding.default,headers: headers)
                    .responseJSON{
                        response in
                        debugPrint(response)
                        if response.result.isSuccess{
                            if let value = response.result.value {
                                let json = JSON(value)
                                if json["code"].int == 401 {
                                    let alertController = UIAlertController(title: "No token,please Log in",
                                                                            message: nil, preferredStyle: .alert)
                                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                        action in
                                        self.performSegue(withIdentifier: "backToRoot", sender: nil)
                                    } )
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }else if json["code"].int == 200{
                                    self.loadOrders()
                                }else{
                                    let alertController = UIAlertController(title: "Fail to Load",
                                                                            message:json["message"].string, preferredStyle: .alert)
                                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                }
            })
            let denyAction = UIAlertAction(title:"Delete",style: .default,handler: {
                action in
                let para:Parameters = ["id": order.id,
                                       "operator": 1]
                let urlString = "http://101.132.185.90:5418/order/confirm"
                let headers:HTTPHeaders = ["token": ((UserDefaults.standard.object(forKey: "token") as? String)!)]
                ViewController.sharedSessionManager.request(urlString, method: .post,parameters: para,  encoding: JSONEncoding.default,headers: headers)
                    .responseJSON{
                        response in
                        debugPrint(response)
                        if response.result.isSuccess{
                            if let value = response.result.value {
                                let json = JSON(value)
                                if json["code"].int == 401 {
                                    let alertController = UIAlertController(title: "No token,please Log in",
                                                                            message: nil, preferredStyle: .alert)
                                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                        action in
                                        self.performSegue(withIdentifier: "backToRoot", sender: nil)
                                    } )
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }else if json["code"].int == 200{
                                    self.loadOrders()
                                }else{
                                    let alertController = UIAlertController(title: "Fail to Load",
                                                                            message:json["message"].string, preferredStyle: .alert)
                                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                }
            })
            alertController.addAction(cancelAction)
            alertController.addAction(confrimAction)
            alertController.addAction(denyAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Detail"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let order = orders[indexPath.row]
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailView = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
            detailView.order = order
            self.present(detailView, animated: true, completion: nil)
            
        }
    }
}

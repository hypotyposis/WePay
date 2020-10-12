//
//  BindingPayViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/9.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class BindingPayViewController: UIViewController {
    @IBOutlet weak var accountTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var tableVIew: UITableView!
    
    var payments = [PaymentModel]()
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
        naviBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        naviBar.shadowImage = UIImage()
        
        accountTableView.backgroundColor = UIColor.clear
        accountTableView.dataSource = self
        accountTableView.delegate = self
        accountTableView.rowHeight = 50
        accountTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        loadPayments()
    }
    
    @IBAction func addPayment(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Payment",
                                                message: "Please enter the bizId and name", preferredStyle: .alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "第三方账号"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "支付方式名称"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "类型（0:支付宝，1:微信）"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            action in
            let bizId = alertController.textFields![0].text
            let name = alertController.textFields![1].text
            let type = alertController.textFields![2].text
            //            print(id! + ralationName! + monthLimit! + singleLimit!)
            let parameters: Parameters = ["bizId": bizId!,
                                          "name": name!,
                                          "paymentType": Int(type!) ?? 0]
            let urlString = "http://101.132.185.90:5418/paymode/addPayMode"
            let headers:HTTPHeaders = ["token": ((UserDefaults.standard.object(forKey: "token") as? String)!)]
            ViewController.sharedSessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: headers)
                .responseJSON { response in
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
                                let alertController = UIAlertController(title: "创建成功",
                                                                        message: nil, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                    action in
                                    self.payments = []
                                    self.loadPayments()
                                })
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }else{
                                let alertController = UIAlertController(title: "创建失败",
                                                                        message: json["message"].string, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                        
                    }
                    
            }
            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    private func loadPayments(){

        let urlString = "http://101.132.185.90:5418/paymode/getAll"
        let headers:HTTPHeaders = ["token": ((UserDefaults.standard.object(forKey: "token") as? String)!)]
        ViewController.sharedSessionManager.request(urlString, method: .get,  encoding: JSONEncoding.default,headers: headers)
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
                            let list = json["data"]["list"].array!
                            //                            let num = json["data"]["size"].int!
                            for item in list{
                                let bizId = item["bizId"].string!
                                let name = item["name"].string!
                                let amount = item["amount"].double!
                                let paymentType = item["paymentType"].int ?? 0
                                let id = item["id"].int!
                                let payment = PaymentModel(bizId: bizId, name: name, paymentType: paymentType, amount: amount,id: id)
                                self.payments += [payment!]
                                }
                            self.tableVIew.reloadData()
                            
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
extension BindingPayViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:
            UITableViewCell.CellStyle.subtitle, reuseIdentifier: nil)
        cell.backgroundColor = UIColor.clear
        cell.textLabel!.font = UIFont(name: "Avenir Next Condensed", size: 20)
        
        let payment = payments[indexPath.row]
        cell.textLabel!.text = payment.name
        cell.detailTextLabel!.text = String(payment.amount)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let payment = payments[indexPath.row]
//        let alertController = UIAlertController(title: payment.name,
//                                                message: payment.bizId, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let deleteAction = UIAlertAction(title: "Delete",style: .default, handler: {
//            action in
//
//
//        })
//
//        alertController.addAction(cancelAction)
//        alertController.addAction(deleteAction)
        tableView.deselectRow(at: indexPath, animated: false)
//        self.present(alertController, animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let payment = payments[indexPath.row]
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let parameters: Parameters = ["payModeId": payment.id]
            let urlString = "http://101.132.185.90:5418/paymode/deletePayMode"
            let headers:HTTPHeaders = ["token": ((UserDefaults.standard.object(forKey: "token") as? String)!)]
            ViewController.sharedSessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: headers)
                .responseJSON { response in
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
                                let alertController = UIAlertController(title: "修改成功",
                                                                        message: nil, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                    action in
                                    self.payments = []
                                    self.loadPayments()
                                })
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }else{
                                let alertController = UIAlertController(title: "修改失败",
                                                                        message: json["message"].string, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                        
                    }else{
                        let alertController = UIAlertController(title: "Unable to connect to the network！",
                                                                message: "Please check your network", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
            }
        }
    }
    
}

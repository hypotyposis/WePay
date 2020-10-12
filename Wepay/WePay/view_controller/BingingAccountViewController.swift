//
//  BingingAccountViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/9.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class BingingAccountViewController: UIViewController{
    @IBOutlet weak var accountTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var tableVIew: UITableView!
    
    var accounts = [AccountRelationModel]()
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
        
        loadAccounts()
        print(accounts.count)
    }
    
    @IBAction func addAccount(_ sender: Any) {
        let alertController = UIAlertController(title: "添加账户",
                                                message: nil, preferredStyle: .alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "绑定用户id"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "关系名称"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "月额度"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "单次额度"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            action in
            let id = alertController.textFields![0].text
            let ralationName = alertController.textFields![1].text
            let monthLimit = alertController.textFields![2].text
            let singleLimit = alertController.textFields![3].text
            if Double(monthLimit!) ?? 0 < Double(singleLimit!) ?? 0 {
                let alertController = UIAlertController(title: "绑定失败",
                                                        message: "月额度不得小于单次额度", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
//            print(id! + ralationName! + monthLimit! + singleLimit!)
            let parameters: Parameters = ["familyId": Int(id!) ?? 0,
                                          "monthLimit": Double(monthLimit!) ?? 0,
                                          "relationName": ralationName!,
                                          "singleLimit":  Double(singleLimit!) ?? 0]
            let urlString = "http://101.132.185.90:5418/relation/sendInvitation"
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
                                let alertController = UIAlertController(title: "发送请求成功",
                                                                        message: "对方接收后请刷新页面", preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                    action in
                                    self.accounts = []
                                    self.loadAccounts()
                                })
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }else{
                                let alertController = UIAlertController(title: "发送请求失败",
                                                                        message: json["message"].string, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                        
                    }
                    
            }
            
//            let account = AccountRelationModel(id: id!, ralationName: ralationName!, monthLimit: Double(monthLimit!)!, singleLimit: Double(singleLimit!)!)
//            self.accounts += [account!]
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    private func loadAccounts(){
        
//        guard let account1 = AccountRelationModel(id: 123, ralationName: "123", monthLimit: 11.2, singleLimit: 11.3) else {
//            fatalError("Unable to instantiate meal1")
//        }
//        accounts += [account1]
        //        rangeOfMeals()
        let urlString = "http://101.132.185.90:5418/relation/getAll"
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
                            let ralationList = json["data"]["relations"].array!
//                            let num = json["data"]["size"].int!
                            for item in ralationList{
                                let id = item["familyId"].int!
                                let mL = item["monthLimit"].double!
                                let sL = item["singleLimit"].double!
                                let rN = item["relationName"].string!
                                let status = item["status"].int!
                                if status == 0{
                                    let account = AccountRelationModel(id: id, ralationName: rN, monthLimit: mL, singleLimit: sL,ralationID: item["id"].int!)
                                    self.accounts += [account!]
                                }
                            }
                            self.tableVIew.reloadData()
                        }else{
                            let alertController = UIAlertController(title: "加载表格失败",
                                                                    message: json["message"].string, preferredStyle: .alert)
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
extension BingingAccountViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        cell.backgroundColor = UIColor.clear
        
        let account = accounts[indexPath.row]
        cell.ralationName.text = account.ralationName
        cell.monthLimit.text = "Month Limit:"+String(account.monthLimit)
        cell.id.text = String(account.id)
        cell.singleLimit.text = "Single Limit:"+String(account.singleLimit)
        
//        let blur = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: blur)
//        blurView.frame = cell.frame
//        blurView.layer.cornerRadius = 12
//        blurView.layer.masksToBounds = true
//        self.tableVIew.insertSubview(blurView, aboveSubview: cell)

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = accounts[indexPath.row]
        let alertController = UIAlertController(title: "编辑绑定账户",
                                                message: nil, preferredStyle: .alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.text = String(account.id)
            textField.isEnabled =  false
            textField.placeholder = "绑定用户id（不可修改）"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.text = account.ralationName
            textField.placeholder = "关系名称"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.text = String(account.monthLimit)
            textField.placeholder = "月额度"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.text = String(account.singleLimit)
            textField.placeholder = "单次额度"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            action in
            let id = alertController.textFields![0].text
            let ralationName = alertController.textFields![1].text
            let monthLimit = alertController.textFields![2].text
            let singleLimit = alertController.textFields![3].text
            if Double(monthLimit!) ?? 0 < Double(singleLimit!) ?? 0 {
                let alertController = UIAlertController(title: "修改失败",
                                                        message: "月额度必须大于单次额度", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            //            print(id! + ralationName! + monthLimit! + singleLimit!)
            let parameters: Parameters = ["familyId": Int(id!) ?? 0,
                                          "monthLimit": Double(monthLimit!) ?? 0,
                                          "relationName": ralationName!,
                                          "singleLimit":  Double(singleLimit!) ?? 0,
                                          "id": account.ralationID
                                            ]
            let urlString = "http://101.132.185.90:5418/relation/update"
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
                                    self.accounts = []
                                    self.loadAccounts()
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
            })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        tableView.deselectRow(at: indexPath, animated: false)
        self.present(alertController, animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let account = accounts[indexPath.row]
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let parameters: Parameters = ["id": account.ralationID,"status":1]
            let urlString = "http://101.132.185.90:5418/relation/update"
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
                                let alertController = UIAlertController(title: "删除成功",
                                                                        message: nil, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                    action in
                                    self.accounts = []
                                    self.loadAccounts()
                                })
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }else{
                                let alertController = UIAlertController(title: "删除失败",
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

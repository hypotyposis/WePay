//
//  ViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/7.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ViewController: UIViewController {

    static let sharedSessionManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        return Alamofire.SessionManager(configuration: configuration)
    }()

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var infoView: UIView!

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
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
        self.view.insertSubview(subview, belowSubview: infoView)
        password.isSecureTextEntry = true
        password.clearButtonMode = .always
        password.placeholder = "请输入密码"
        password.placeholderFont = UIFont.init(name: "Avenir Next Condensed", size: 20)!
        
        username.clearButtonMode = .always;
        username.placeholder = "请输入注册手机号"
        username.placeholderFont = UIFont.init(name: "Avenir Next Condensed", size: 20)!
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        iconImageView.image = iconImageView.image?.toCircle()
        
        
    }
   
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        let urlString = "http://101.132.185.90:5418/account/getAvatar/" + username.text!
        
        ViewController.sharedSessionManager.request(urlString, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                //                debugPrint(response)
                if response.result.isSuccess{
                    if let value = response.result.value {
                        let json = JSON(value)
                        //                        print(json)
                        if json["code"].int == 200 {
                            let url = URL(string: json["data"]["avatar"].string!)
                            do{
                                let data = try Data(contentsOf: url!)
                                self.iconImageView.image = UIImage(data: data)?.toCircle()
                            }catch let error as NSError{
                                print(error)
                            }
                        }else{
                            self.iconImageView.image = UIImage(named: "mainicon")
                        }
                    }
                }else{
                }
        }
        self.view.endEditing(true)
    }
    
    @IBAction func signinSuccess(_ sender: Any) {
        
        print("touch Button")
        let parameters: Parameters = ["password": password.text!,"phone":username.text!]
        
        let urlString = "http://101.132.185.90:5418/account/common/login"
        
        ViewController.sharedSessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                if response.result.isSuccess{
                    if let value = response.result.value {
                        let json = JSON(value)
                        //                        print(json)
                        if json["code"].int == 200 {
                            let userDefaults = UserDefaults.standard
                            userDefaults.set(json["data"]["userInfo"]["username"].string, forKey: "username")
                            userDefaults.set(self.password.text!, forKey: "password")
                            userDefaults.set(json["data"]["userInfo"]["phoneNumber"].string, forKey: "phoneNumber")
                            userDefaults.set(json["data"]["userInfo"]["avatar"].string, forKey: "avatar")
                            userDefaults.synchronize()
                            let alertController = UIAlertController(title: "登录成功",
                                                                    message: nil, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                action in
                                let userDefaults = UserDefaults.standard
                                userDefaults.set(json["data"]["token"].string, forKey: "token")
                                self.performSegue(withIdentifier: "showUserView", sender: nil)
                            } )
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }else{
                            let alertController = UIAlertController(title: "用户名密码错误！",
                                                                    message: "请输入正确的用户名密码", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                                action in
                                self.password.text = ""
                                self.username.text = ""
                            })
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }else{
                    print("Net Failure")
                    let alertController = UIAlertController(title: "Unable to connect to the network！",
                                                            message: "Please check your network", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
        }
//        print(canPerform)
//        if canPerform == true{
//            self.performSegue(withIdentifier: "showUserView", sender: nil)
//        }
    }



}


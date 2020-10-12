//
//  InfoModifyViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/9.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InfoModifyViewController: UIViewController {

    static let sharedSessionManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        return Alamofire.SessionManager(configuration: configuration)
    }()
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var naviBar:UINavigationBar!
    
    @IBOutlet weak var usernameTextField: UITextField!

    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var phonenumberTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!

//    var user:User?
    var countdownTimer: Timer?
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                remainingSeconds = 30
                sendMessageButton.tintColor = UIColor.gray
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                sendMessageButton.tintColor = UIColor.lightGray
            }
            
            sendMessageButton.isEnabled = !newValue
        }
    }
    
    var remainingSeconds: Int = 0 {
        willSet {
            sendMessageButton.setTitle("(\(newValue)s)", for: .normal)
            
            if newValue <= 0 {
                sendMessageButton.setTitle("发送信息", for: .normal)
                isCounting = false
            }
        }
    }
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
        
        let userDefaults = UserDefaults.standard
        usernameTextField.text = userDefaults.object(forKey: "username") as? String
//        passwdTextField.text = userDefaults.object(forKey: "password") as? String
        phonenumberTextField.text = userDefaults.object(forKey: "phoneNumber") as? String
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        let username = UserDefaults.standard.object(forKey: "phoneNumber") as! String
        let urlString = "http://101.132.185.90:5418/account/getAvatar/" + username
        
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
                                self.iconImage.image = UIImage(data: data)?.toCircle()
                            }catch let error as NSError{
                                print(error)
                            }
                        }else{
                            
                        }
                    }
                }else{
                }
        }
       
    }
    
    @IBAction func touchSaveButton(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        var canPerformSegue = true
        var needToken = false
        if usernameTextField.text != "" && usernameTextField.text != (userDefaults.object(forKey: "username") as? String){
            userDefaults.set(usernameTextField.text, forKey: "username")
        }
        if passwdTextField.text != "" && passwdTextField.text != (userDefaults.object(forKey: "password") as? String){
            if(confirmPassTextField.text == passwdTextField.text){
                userDefaults.set(passwdTextField.text, forKey: "password")
                needToken = true
            }else{
                let alertController = UIAlertController(title: "非法密码！",
                                                        message: "两次密码不一致!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                    action in
                    self.passwdTextField.text = ""
                    self.confirmPassTextField.text = ""
                })
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                canPerformSegue = false
            }
        }
        if phonenumberTextField.text != "" && phonenumberTextField.text != (userDefaults.object(forKey: "phoneNumber") as? String){
            let authCode = codeTextField.text
            let phoneNum = phonenumberTextField.text
            SMSSDK.commitVerificationCode(authCode, phoneNumber: phoneNum, zone: "86" ,
                    result:{ error -> Void in
                        if(error == nil){
                            userDefaults.set(self.phonenumberTextField.text, forKey: "phoneNumber")
                            print("auth success")
                        }else{
                            let alertController = UIAlertController(title: "Can't auth the phone number!",message: "Illegal authCode!", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                                action in
                                self.codeTextField.text = ""
                                self.phonenumberTextField.text = ""
                            })
                            alertController.addAction(cancelAction)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            self.phonenumberTextField.isEnabled = true
                            print("auth fail！%@" , error)
                            canPerformSegue = false
                        }
            })
        }
//        userDefaults.synchronize()
        if canPerformSegue == true{
            let parameters: Parameters = ["password": UserDefaults.standard.object(forKey: "password") as! String,
                                          "phone": UserDefaults.standard.object(forKey: "phoneNumber") as! String,
                                          "username": UserDefaults.standard.object(forKey: "username") as! String]
            let urlString = "http://101.132.185.90:5418/account/update"
            let headers:HTTPHeaders = ["token": ((UserDefaults.standard.object(forKey: "token") as? String)!)]
            InfoModifyViewController.sharedSessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default,headers:headers )
                .responseJSON { response in
                    debugPrint(response)
                    if response.result.isSuccess{
                        if let value = response.result.value {
                            let json = JSON(value)
                            //                        print(json)
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
                                let alertController = UIAlertController(title: "修改成功！",
                                                                        message: nil, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                    action in
                                    if needToken{
                                        UserDefaults.standard.set(json["data"]["token"].string!, forKey: "token")
                                    }
                                    self.performSegue(withIdentifier: "backToHome", sender: nil)
                                })
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }else{
                                let alertController = UIAlertController(title: "修改失败",
                                                                        message: json["message"].string, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                    action in
                                    self.performSegue(withIdentifier: "backToHome", sender: nil)
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
            performSegue(withIdentifier: "backToHome", sender: nil)
        }
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    @objc func updateTime(timer: Timer) {
            // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let phoneNum = phonenumberTextField.text
        if phoneNum != ""{
            phonenumberTextField.isEnabled = false
            SMSSDK.getVerificationCode(by: SMSGetCodeMethod.SMS, phoneNumber: phoneNum, zone: "86", result: {
                error in
                if(error == nil){
                    print("send success")
                    self.isCounting = true
                }else{
                    print("send fail %@" ,error)
                    let alertController = UIAlertController(title: "发送短信失败",message: "非法的手机号码!", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                        action in
                        self.phonenumberTextField.text = ""
                    })
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            })
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

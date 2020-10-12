//
//  ChangePasswdViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/14.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ChangePasswdViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var naviBar:UINavigationBar!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var phonenumberTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    
    var keyBoardNeedLayout: Bool = true
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        //        NotificationCenter.default.addObserver(self,selector:#selector(self.kbFrameChanged(_:)),name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @IBAction func touchSaveButton(_ sender: Any) {
        let authCode = codeTextField.text
        let phoneNum = phonenumberTextField.text
        SMSSDK.commitVerificationCode(authCode, phoneNumber: phoneNum, zone: "86" ,
                                      result:{ error -> Void in
                                        if(error == nil){
                                            print("auth success")
                                            let alertController = UIAlertController(title: "重新设置密码",
                                                                                    message: nil, preferredStyle: .alert)
                                            alertController.addTextField {
                                                (textField: UITextField!) -> Void in
                                                textField.placeholder = "新密码"
                                            }
                                            alertController.addTextField {
                                                (textField: UITextField!) -> Void in
                                                textField.placeholder = "确认新密码"
                                            }
                                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                            let okAction = UIAlertAction(title: "Confirm", style: .default, handler: {
                                                action in
                                                let passwd = alertController.textFields![0].text
                                                let confirmPasswd = alertController.textFields![1].text
                                                if passwd != confirmPasswd{
                                                    alertController.textFields![1].text = ""
                                                }else{
                                                    let parameters: Parameters = ["password": passwd!,"phoneNumber": phoneNum!]
                                                    let urlString = "http://101.132.185.90:5418/account/retrievePassword"
                                                    ViewController.sharedSessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                                                        .responseJSON { response in
                                                            debugPrint(response)
                                                            if response.result.isSuccess{
                                                                if let value = response.result.value {
                                                                    let json = JSON(value)
                                                                    if json["code"].int == 200 {
                                                                        let alertController = UIAlertController(title: "修改成功",
                                                                                                                message: nil, preferredStyle: .alert)
                                                                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                                                                            action in
                                                                            self.performSegue(withIdentifier: "backToHome", sender: nil)
                                                                        })
                                                                        alertController.addAction(cancelAction)
                                                                        self.present(alertController, animated: true, completion: nil)
                                                                        
                                                                    }else{
                                                                        let alertController = UIAlertController(title: "修改失败",
                                                                                                                message: json["message"].string, preferredStyle: .alert)
                                                                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
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
                                            })
                                            alertController.addAction(cancelAction)
                                            alertController.addAction(okAction)
                                            self.present(alertController, animated: true, completion: nil)
                                        }else{
                                            let alertController = UIAlertController(title: "Can't auth the phone number!",message: "Wrong authCode!", preferredStyle: .alert)
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
                                        }
        })
        
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    @objc func updateTime(timer: Timer) {
        remainingSeconds -= 1
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let phoneNum = phonenumberTextField.text
        if phoneNum != ""{
            //            phonenumberTextField.isEnabled = false
            SMSSDK.getVerificationCode(by: SMSGetCodeMethod.SMS, phoneNumber: phoneNum, zone: "86", result: {
                error in
                if(error == nil){
                    print("send success")
                    self.isCounting = true
                }else{
                    print("send fail %@" ,error)
                    let alertController = UIAlertController(title: "Can't send the message",message: "Illegal phone number!", preferredStyle: .alert)
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

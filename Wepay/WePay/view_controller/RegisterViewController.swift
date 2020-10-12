//
//  RegisterViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/14.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class RegisterViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var naviBar:UINavigationBar!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
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
                sendMessageButton.setTitle("Send Message", for: .normal)
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
        enum status{
            case emptyField
            case wrongPass
            case wrongPhone
            case ok
        }
        var performStatus = status.ok
        
        if usernameTextField.text == "" || passwdTextField.text == "" || phonenumberTextField.text == ""{
            performStatus = status.emptyField
        }
        if passwdTextField.text != ""{
            
            if(confirmPassTextField.text != passwdTextField.text){
                performStatus = status.wrongPass
            }
        }
        if phonenumberTextField.text != ""{
            let authCode = codeTextField.text
            let phoneNum = phonenumberTextField.text
            SMSSDK.commitVerificationCode(authCode, phoneNumber: phoneNum, zone: "86" ,
                                          result:{ error -> Void in
                                            if(error == nil){
                                                print("auth success")
                                            }else{
                                                let alertController = UIAlertController(title: "Can't auth the phone number!",message: "Illegal authCode!", preferredStyle: .alert)
                                                let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
                                                let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                                                    action in
                                                    self.codeTextField.text = ""
                                                    self.phonenumberTextField.text = ""
//                                                    self.phonenumberTextField.isEnabled = true
                                                })
                                                alertController.addAction(cancelAction)
                                                alertController.addAction(okAction)
                                                self.present(alertController, animated: true, completion: nil)
                                                print("auth fail！%@" , error)
                                                performStatus = .wrongPhone
                                            }
            })
        }
        if performStatus == .ok{
            let parameters: Parameters = ["password": passwdTextField.text!,
                                          "phone": phonenumberTextField.text!,
                                          "username": usernameTextField.text!]
            let urlString = "http://101.132.185.90:5418/account/common/register"
            ViewController.sharedSessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseJSON { response in
                    debugPrint(response)
                    if response.result.isSuccess{
                        if let value = response.result.value {
                            let json = JSON(value)
                            //                        print(json)
                            if json["code"].int == 200 {
                                let alertController = UIAlertController(title: "Register Success!",
                                                                        message: nil, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:{
                                    action in
                                    self.performSegue(withIdentifier: "backToHome", sender: nil)
                                } )
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }else{
                                let alertController = UIAlertController(title: json["message"].string!,
                                                                        message: json["message"].string!, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                                    action in
                                    self.passwdTextField.text = ""
                                    self.usernameTextField.text = ""
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
//            performSegue(withIdentifier: "backToHome", sender: nil)
        }
        else if performStatus == .emptyField{
            let alertController = UIAlertController(title: "Empty field!",
                                                    message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else if performStatus == .wrongPass{
            let alertController = UIAlertController(title: "Two passwords entered are inconsistent!",
                                                    message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else if performStatus == .wrongPhone{
            let alertController = UIAlertController(title: "Phone Validation Failure！",
                                                    message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
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
//    @objc func kbFrameChanged(_ notification : Notification){
//           let info = notification.userInfo
//           let kbRect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//           let offsetY = kbRect.origin.y - UIScreen.main.bounds.height
//           UIView.animate(withDuration: 0.3) {
//           self.contentView.transform = CGAffineTransform(translationX: 0, y: offsetY)
////           self.codeTextField.transform = CGAffineTransform(translationX: 0, y: -offsetY)
//            }
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */


}

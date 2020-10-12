//
//  QRCodeViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/13.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit

import AVFoundation
import SwiftyJSON
import Alamofire

class QRCodeViewController: LBXScanViewController,LBXScanViewControllerDelegate {
    var activityIndicator:UIActivityIndicatorView!
    var orderId:Int = 0
    var orderStatus = -1
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        let result = scanResult.strScanned!
        createOrder(result: result)
//        while checkOrder(){
//
//        }
    }
    func play(){
        //开始转动
        activityIndicator.startAnimating()
        //显示当前状态
        print(activityIndicator.isAnimating)
    }
    func stop(){
        //停止转动
        activityIndicator.stopAnimating()
        //显示当前转台
        print(activityIndicator.isAnimating)
    }
    func checkOrder()->Bool{
        
        return true
    }
    func createOrder(result:String){
        let results = result.split(separator: ",")
        print(result.split(separator: ","))
        let itemIdsStr = results[0].split(separator: "/")
        var itemIds:[Int] = []
        for item in itemIdsStr{
            let itemId = Int(item)
            itemIds += [itemId!]
        }
        let payment = Double(results[1])
        let payType = results[2].replacingOccurrences(of: "/", with: ",")
        let parameters: Parameters = ["itemIds": itemIds,
                                      "payment": payment ?? 0,
                                      "paymentType": payType,
                                      "sellerId": 10]
        let urlString = "http://101.132.185.90:5418/order/createOrder"
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
                                self.orderId = json["data"]["orderId"].int!
                                //设置环形滚动条的样式
                                self.activityIndicator = UIActivityIndicatorView(style: .white)
                                //设置环形滚动条颜色
                                self.activityIndicator.color = UIColor.lightGray
                                //设置环形滚动条背景颜色
                                self.activityIndicator.backgroundColor = UIColor.clear
                                //设置位置
                                self.activityIndicator.center = self.view.center
                                //停止转圈时，隐藏(默认为true)
                                self.activityIndicator.hidesWhenStopped = false
                                self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
                                self.view.addSubview(self.activityIndicator)
                                self.play()
                                Timer.scheduledTimer(timeInterval: 1,target:self,selector:#selector(self.tickDown),
                                                                               userInfo:nil,repeats:true)
                            }else{
                                let alertController = UIAlertController(title: "创建订单失败！",
                                                                        message: json["message"].string, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }

                    }

            }
        
    }
    @objc func tickDown(){
        if orderId != 0{
            let urlString = "http://101.132.185.90:5418/order/queryStatus/" + String(orderId)
            let headers:HTTPHeaders = ["token": ((UserDefaults.standard.object(forKey: "token") as? String)!)]
            ViewController.sharedSessionManager.request(urlString, method: .get, encoding: JSONEncoding.default,headers: headers)
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
                                let newStatus = json["data"]["status"].int!
                                if newStatus != self.orderStatus{
                                    self.orderStatus = newStatus
                                    self.stop()
                                    let alertController = UIAlertController(title: "订单支付成功",
                                                                            message: nil, preferredStyle: .alert)
                                    let cancelAction = UIAlertAction(title: "OK", style: .default, handler:{
                                        action in
                                        self.performSegue(withIdentifier: "backtohome", sender: nil)
                                    } )
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }else{
                                let alertController = UIAlertController(title: "查看状态失败",
                                                                        message: json["message"].string, preferredStyle: .alert)
                                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                        
                    }
                    
            }
        }
        
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        LBXPermissions.authorizeCameraWith { [weak self] (granted) in
            if granted {
                self?.scanQrCode()
            } else {
                LBXPermissions.jumpToSystemPrivacySetting()
            }
        }
    }
    func scanQrCode() {
        //设置扫码区域参数
        var style = LBXScanViewStyle()
        style.centerUpOffset = 60;
        style.xScanRetangleOffset = 30;
        if UIScreen.main.bounds.size.height <= 480 {
            //3.5inch 显示的扫码缩小
            style.centerUpOffset = 40;
            style.xScanRetangleOffset = 20;
        }
        style.color_NotRecoginitonArea = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.4)
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner;
        style.photoframeLineW = 2.0;
        style.photoframeAngleW = 16;
        style.photoframeAngleH = 16;
        style.isNeedShowRetangle = false;
        style.anmiationStyle = LBXScanViewAnimationStyle.NetGrid;
        style.animationImage = UIImage(named: "qrcode_scan_full_net")
        self.scanStyle = style
        self.scanResultDelegate = self
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

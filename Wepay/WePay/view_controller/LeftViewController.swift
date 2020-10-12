//
//  LeftViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/8.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class LeftViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var phonenumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mainIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var iconRect:CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let taget = UITapGestureRecognizer(target:self, action:#selector(self.selectIcon))
        mainIcon.isUserInteractionEnabled = true
        mainIcon.addGestureRecognizer(taget)
//        NSURL url =[NSURL URLWithString:[CommonTool getImageUrlString:self.imageNameA[i]]];
//        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        let usernameStr = UserDefaults.standard.object(forKey: "phoneNumber") as! String
        let urlString = "http://101.132.185.90:5418/account/getAvatar/" + usernameStr
        
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
                                self.mainIcon.image = UIImage(data: data)?.toCircle()
                            }catch let error as NSError{
                                print(error)
                            }
                        }else{
                            
                        }
                    }
                }else{
                }
        }
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
      
//        let user = User()
//        let fileData = NSMutableData(contentsOfFile: user.filePath)
//        if fileData != nil {
//            do{
//                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: fileData! as Data)
//                let saveUser = unarchiver.decodeObject(forKey: "userKey") as! User
//                unarchiver.finishDecoding()
//                usernameLabel.text = "Welcome " + saveUser.username!
//                phonenumberLabel.text = saveUser.phonenumber!
//            }catch{
//                print("wrong unarchive")
//            }
//        }
        let userDefaults = UserDefaults.standard
        usernameLabel.text = userDefaults.object(forKey: "username") as? String
        if usernameLabel.text == ""{
            usernameLabel.text = "Visitor"
        }
        let phoneNumber = userDefaults.object(forKey: "phoneNumber") as? String
        phonenumberLabel.text = (phoneNumber?.prefix(3))! + "***" + (phoneNumber?.suffix(4))!
   
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            fatalError("Expected a dictionary containing an image,but was provided the following:\(info)")
        }
        let cutSelectedImage = selectedImage.toCircle()
        let header :HTTPHeaders = ["token": UserDefaults.standard.object(forKey: "token") as! String]
        ViewController.sharedSessionManager.upload(
            multipartFormData:
            {
                (FormData) in
                FormData.append(selectedImage.pngData()!, withName: "avatar", fileName: "avatar.png", mimeType: "image/png")
            },
            to: "http://101.132.185.90:5418/account/changeAvatar",
            headers:header,
            encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON{ response in
                    debugPrint(response)
                }
            case .failure(let error):
                print(error)
            }
        })
        
        
        mainIcon.image = cutSelectedImage
        
        dismiss(animated: true, completion: nil)
    }
    //MARK: actions
    @objc func selectIcon(){
//        print("tap")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController,animated: true,completion: nil)
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
extension LeftViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:
            UITableViewCell.CellStyle.subtitle, reuseIdentifier: nil)
        cell.backgroundColor = UIColor.clear
        cell.textLabel!.font = UIFont(name: "Avenir Next Condensed", size: 20)
        switch indexPath.row {
        case 0:
            cell.textLabel!.text = "统计图表"
            cell.imageView!.image = UIImage(named:"payment")
        case 1:
            cell.textLabel!.text = "修改信息"
            cell.imageView!.image = UIImage(named:"selfinfo")
        case 2:
            cell.textLabel!.text = "绑定账户"
            cell.imageView!.image = UIImage(named:"bindingaccount")
        case 3:
            cell.textLabel!.text = "支付方式"
            cell.imageView!.image = UIImage(named:"payment")
        case 4:
            cell.textLabel!.text = "信息"
            cell.imageView!.image = UIImage(named:"message")
        case 5:
            cell.textLabel!.text = "关于我们"
            cell.imageView!.image = UIImage(named:"help")
        case 6:
            cell.textLabel!.text = "退出"
            cell.imageView!.image = UIImage(named:"exit")
        default:
            print("wrong index")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "pushRecord", sender: self)
        case 1:
            performSegue(withIdentifier: "pushInfo", sender: self)
        case 2:
            performSegue(withIdentifier: "pushBinding", sender: self)
        case 3:
            performSegue(withIdentifier: "pushPay", sender: self)
        case 4:
            performSegue(withIdentifier: "pushNews", sender: self)
        case 5:
            performSegue(withIdentifier: "pushAbout", sender: self)
        default:
            let alertController = UIAlertController(title: "Exit OR Logout", message: "Exit the program or back to homepage",
                                                    preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let logoutAction = UIAlertAction(title: "Log out", style: .default, handler: {(alerts:UIAlertAction) -> Void in
                print("Log out")
                UserDefaults.standard.set("",forKey: "token")
                self.performSegue(withIdentifier: "logout", sender: nil)
            })
            let exitAction = UIAlertAction(title: "Exit", style: .default, handler: {(alerts:UIAlertAction) -> Void in
                print("Exit")
                UserDefaults.standard.set("",forKey: "token")
                UIView.beginAnimations("exitApplication", context: nil)
                UIView.setAnimationDuration(0.5)
                UIView.setAnimationDelegate(self)
                UIView.setAnimationTransition(.flipFromLeft, for: self.view.window!, cache: false)
                UIView.setAnimationDidStop(#selector(LeftViewController.animationFinished(_:finished:context:)))
                self.view.window!.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
                UIView.commitAnimations()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(logoutAction)
            alertController.addAction(exitAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @objc func animationFinished(_ animationID: String?, finished: NSNumber?, context: UnsafeMutableRawPointer?) {
        if animationID?.compare("exitApplication").rawValue == 0 {
            exit(0)
        }
    }
}

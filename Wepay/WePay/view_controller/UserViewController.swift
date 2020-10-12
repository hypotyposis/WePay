//
//  WelcomeViewController.swift
//  WePay
//
//  Created by Wallance on 2019/7/7.
//  Copyright © 2019 Wallance. All rights reserved.
//

import UIKit
import SWRevealViewController
import Charts
import SwiftyJSON
import Alamofire

class UserViewController: UIViewController, ChartViewDelegate, FloatDelegate{
    func singleClick() {
        
    }
    
    func repeatClick() {
        performSegue(withIdentifier: "scan", sender: nil)

    }
    
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var naviBar: UINavigationBar!
    
    var chartView: BarChartView!
    let xStr = ["Mon", "Tue", "Wed", "Thu","Fri", "Sat","Sun"]
    var values:[Double] = []

    var pieChartView: PieChartView!
    var pieStr:[String] = []
    var units:[Double] = []
    
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
        self.view.insertSubview(subview, belowSubview: contentView)
        
        if let revealVC = revealViewController(){
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
            menuButton.target = revealVC
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        naviBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        naviBar.shadowImage = UIImage()
        
        loadChartData()
        
        
        let frame = CGRect.init(x: 300, y: 100, width: 100, height: 100)
        let allbutton = AllFloatButton.init(frame: frame)
        allbutton.delegate = self
        allbutton.setImage(UIImage.init(named: "camera"), for: .normal)
        allbutton.backgroundColor = UIColor.clear
        self.view.addSubview(allbutton)
    }
    
    func setBarChartViewData(_ dataPoints: [String], _ values: [Double]) {
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: "Avenir Next Condensed", size: 15)!
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1.0
        xAxis.valueFormatter = self
        let xFormatter = IndexAxisValueFormatter()
        xFormatter.values = dataPoints
        
        var dataEntris: [BarChartDataEntry] = []
        for (idx, _) in dataPoints.enumerated() {
            let dataEntry = BarChartDataEntry(x: Double(idx), y: values[idx])
            dataEntris.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntris, label: "")
        let color = UIColor.lightGray
        chartDataSet.colors = [color, color, color, color, color]
        let chartData = BarChartData(dataSet: chartDataSet)
        
        self.chartView.data = chartData
        self.chartView.animate(yAxisDuration: 0.4)
    }
    
    func setPieChartViewData(_ dataPoints: [String], _ values: [Double]){
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let entry = PieChartDataEntry(value: values[i], label: "\(dataPoints[i])")
            dataEntries.append(entry)
        }
        
        
        let pichartDataSet = PieChartDataSet(entries: dataEntries, label: "产品")
        setPieChartDataSetConfig(pichartDataSet: pichartDataSet)
        
        
        let pieChartData = PieChartData(dataSet: pichartDataSet)
        setPieChartDataConfig(pieChartData: pieChartData)
        pieChartView.data = pieChartData
        setDrawHoleState()
        
        var colors: [UIColor] = []
        for _ in 0..<dataPoints.count {
            colors.append(UIColor.randomColor)
        }
        
        pichartDataSet.colors = colors
    }
    func setPieChartDataSetConfig(pichartDataSet: PieChartDataSet){
        pichartDataSet.sliceSpace = 0 //相邻区块之间的间距
        pichartDataSet.selectionShift = 8 //选中区块时, 放大的半径
        pichartDataSet.xValuePosition = .insideSlice //名称位置
        pichartDataSet.yValuePosition = .outsideSlice //数据位置
        //数据与区块之间的用于指示的折线样式
        pichartDataSet.valueLinePart1OffsetPercentage = 0.85
        //折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
        pichartDataSet.valueLinePart1Length = 0.5 //折线中第一段长度占比
        pichartDataSet.valueLinePart2Length = 0.4 //折线中第二段长度最大占比
        pichartDataSet.valueLineWidth = 1 //折线的粗细
        pichartDataSet.valueLineColor = UIColor.gray //折线颜色
        
        
    }
    
    //设置饼状图字体样式
    func setPieChartDataConfig(pieChartData: PieChartData){
        pieChartData.setValueFormatter(DigitValueFormatter())//设置百分比
        
        pieChartData.setValueTextColor(UIColor.gray) //字体颜色为白色
        pieChartData.setValueFont(UIFont.systemFont(ofSize: 10))//字体大小
    }
    
    
    //设置饼状图中心文本
    func setDrawHoleState(){
        ///饼状图距离边缘的间隙
        pieChartView.setExtraOffsets(left: 30, top: 0, right: 30, bottom: 0)
        //拖拽饼状图后是否有惯性效果
        pieChartView.dragDecelerationEnabled = true
        //是否显示区块文本
        pieChartView.drawSlicesUnderHoleEnabled = true
        //是否根据所提供的数据, 将显示数据转换为百分比格式
        pieChartView.usePercentValuesEnabled = true
        
        // 设置饼状图描述
        pieChartView.chartDescription?.text = "产品种类"
        pieChartView.chartDescription?.font = UIFont.init(name: "Avenir Next Condensed", size: 15)!
        pieChartView.chartDescription?.textColor = UIColor.gray
        
        // 设置饼状图图例样式
        pieChartView.legend.maxSizePercent = 1 //图例在饼状图中的大小占比, 这会影响图例的宽高
        pieChartView.legend.formToTextSpace = 5 //文本间隔
        pieChartView.legend.font = UIFont.systemFont(ofSize: 10) //字体大小
        pieChartView.legend.textColor = UIColor.gray //字体颜色
        pieChartView.legend.verticalAlignment = .bottom //图例在饼状图中的位置
        pieChartView.legend.form = .circle //图示样式: 方形、线条、圆形
        pieChartView.legend.formSize = 12 //图示大小
        pieChartView.legend.orientation = .horizontal
        pieChartView.legend.horizontalAlignment = .center
        
        ////饼状图中心的富文本文本
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: CGFloat(15.0)), NSAttributedString.Key.foregroundColor: UIColor.gray]
        let centerTextAttribute = NSAttributedString(string: "Products", attributes: attributes)
        pieChartView.centerAttributedText = centerTextAttribute
        
        pieChartView.setNeedsDisplay()
    }
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//        let al = UIAlertController.init(title: nil, message: "\(pieStr[Int(highlight.x)])  \(highlight.y)", preferredStyle: .alert)
//        let cancel = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
////        al.addAction(cancel)
//        self.present(al, animated: true, completion: nil)
    }
    func loadChartData(){
        let header : HTTPHeaders = ["token": UserDefaults.standard.object(forKey: "token") as! String]
        let urlString = "http://101.132.185.90:5418/statistic/histogram/oneWeek"
        ViewController.sharedSessionManager.request(urlString, method: .get, encoding: JSONEncoding.default,headers: header)
            .responseJSON { response in
                print("loading1……")
//                debugPrint(response)
                if response.result.isSuccess{
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["code"].int == 200 {
                            let statistics = json["data"]["statistics"].array!
                            for item in statistics{
                                self.values += [item["amount"].double!]
                            }
                            self.chartView = BarChartView()
                            self.chartView.frame = CGRect(x: 0, y: 80, width: 300, height: 300)
                            self.chartView.center.x = self.view.center.x
                            self.view.addSubview(self.chartView)
                            self.setBarChartViewData(self.xStr, self.values)
                            
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
        
        
        let urlString2 = "http://101.132.185.90:5418/statistic/pieChart/oneWeek"
        ViewController.sharedSessionManager.request(urlString2, method: .get, encoding: JSONEncoding.default,headers: header)
            .responseJSON { response in
                print("loading2……")
//                debugPrint(response)
                if response.result.isSuccess{
                    if let value = response.result.value {
                        let json = JSON(value)
                        if json["code"].int == 200 {
                            let statistics = json["data"]["statistics"].array!
                            for item in statistics{
                                self.pieStr += [item["catalog"].string!]
                                self.units += [item["amount"].double!]
                            }
                            
                            self.pieChartView = PieChartView()
                            self.pieChartView.backgroundColor = UIColor.clear
                            self.pieChartView.frame = CGRect(x: 0, y: 400, width: 300, height: 300)
                            self.pieChartView.delegate = self
                            self.pieChartView.center.x = self.view.center.x
                            self.view.addSubview(self.pieChartView)
                            self.setPieChartViewData(self.pieStr, self.units)
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
//        let blur = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: blur)
//        blurView.frame = chartView.frame
//        blurView.layer.cornerRadius = 30
//        blurView.layer.masksToBounds = false
//        self.view.insertSubview(blurView, belowSubview: chartView)
        
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
extension UserViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xStr[Int(value) % xStr.count]
    }
}
class DigitValueFormatter: NSObject, IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let valueWithoutDecimalPart = String(format: "%.2f%%", value)
        return valueWithoutDecimalPart
        
    }
}

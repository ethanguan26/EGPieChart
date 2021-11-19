//
//  EGPieChartDemoController.swift
//  EGPieChartDemo
//
//  Copyright (c) 2021 Ethan Guan
//  https://github.com/GuanyiLL/EGPieChart

import UIKit
import EGPieChart

class EGPieChartDemoController: UIViewController {
    
    @IBOutlet weak var pieChartView: EGPieChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        pieChartView.drawOutsideValues = true
        pieChartView.line1AnglarOffset = 0.2
        pieChartView.line1Persentage = 0.95
        pieChartView.line1Lenght = 20
        pieChartView.line2Length = 15
        
        requestDatas()
    }
    
    func requestDatas() {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0)
            DispatchQueue.main.async {
                let testDataArr: [CGFloat] = [55.2, 190.4, 85.3, 100.5, 150.72]
                var datas = [EGPieChartData]()
                for i in 0..<testDataArr.count {
                    let data = EGPieChartData(value: testDataArr[i],
                                              content: "\(testDataArr[i])")
                    datas.append(data)
                }
                let dataSource = EGPieChartDataSource(datas: datas)
                dataSource.setAllValueFont(.systemFont(ofSize: 11))
                dataSource.setAllValueTextColor(UIColor.black)
                
                let colors: [UIColor] = [.red, .green, .orange, .cyan, .lightGray]
                dataSource.fillColors = colors
                
                let content = NSString(string: "I'm a Pie Chart")
                let range = content.range(of: "Pie Chart")
                let attr = NSMutableAttributedString(string: String(content))
                attr.setAttributes([.foregroundColor: UIColor.blue, .font: UIFont.systemFont(ofSize: 14)], range: range)
                dataSource.centerAttributeString = attr.copy() as? NSAttributedString
                self.pieChartView.drawCenter = true
                self.pieChartView.dataSource = dataSource
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieChartView.frame = CGRect(x: view.center.x - view.frame.width / 2, y: view.center.y - view.frame.width / 2, width: view.frame.width, height: view.frame.width)
        pieChartView.outerRadius = view.frame.width / 2.0 - 50.0
        //        pieChartView.innerRadius = 70.0
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

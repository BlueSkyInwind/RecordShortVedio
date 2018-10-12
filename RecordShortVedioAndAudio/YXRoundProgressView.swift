//
//  YXRoundProgressView.swift
//  ShortVideoRecording
//
//  Created by admin on 2017/12/19.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit

class YXRoundProgressView: UIView {
    //最大的时间值
    var timeMax:Double{
        didSet {
            self.progressValue = 0
            self.currentTime = 0
            self.setNeedsDisplay()
            self.isHidden = false
            self.perform(#selector(startProgress), with: self, afterDelay: 0.1)
        }
    }
    
    var progressValue:Float  //进度值在0-1.0之间
    var currentTime:Double //当前进度值
    
    override init(frame: CGRect) {
        self.timeMax = 0.0
        self.currentTime = 0.0
        self.progressValue = 0.0
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let ctx = UIGraphicsGetCurrentContext()
        let centerPoint = CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        let radius = self.bounds.size.width/2.0 - 3 //设置半径
        let startA = -(Double.pi / 2)   //起点位置
        let endA = -(Double.pi / 2) + Double.pi * 2 * Double(progressValue) //终点位置
        
        let path = UIBezierPath.init(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(startA), endAngle: CGFloat(endA), clockwise: true)
        ctx?.setLineWidth(5) //设置线条宽度
        UIColor.green.setStroke()
        ctx?.addPath(path.cgPath)
        ctx?.strokePath()
        
    }
    
    @objc func startProgress() {
        currentTime += 0.1
        if currentTime < timeMax {
            progressValue = Float(currentTime/timeMax)
            print(progressValue)
            setNeedsDisplay()
            self.perform(#selector(startProgress), with: nil, afterDelay: 0.1)
        }
        else{
            clearProgress()
        }
    }
    
    func clearProgress()  {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        currentTime = timeMax;
        self.currentTime = 0.0
        self.progressValue = 0.0
        setNeedsDisplay()
//      self.isHidden = true;
    }
    
}

//
//  YXRecordView.swift
//  ShortVideoRecording
//
//  Created by admin on 2017/12/11.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit

typealias RecordButtonClick = () -> Void
typealias StopRecordButtonClick = () -> Void
typealias AfreshButtonClick = () -> Void
typealias EnsureButtonClick = () -> Void

let Click_CenterPoint = CGPoint.init(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height - 100)

class YXRecordView: UIView {

    var afreshBtn:UIButton?
    var ensureBtn:UIButton?
    var changeDeviceBtn:UIButton?
    
    var centerRoundView:UIView?
    var bgView:YXRoundProgressView?
    
    var recordButtonClick:RecordButtonClick?
    var stopRecordButtonClick:StopRecordButtonClick?
    var afreshButtonClick:AfreshButtonClick?
    var ensureButtonClick:EnsureButtonClick?
    
    override init(frame: CGRect) {
         super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == centerRoundView {
            print("开始录制")
            if recordButtonClick != nil {
                self.recordButtonClick!()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == centerRoundView {
            print("结束录制")
            if stopRecordButtonClick != nil {
                self.stopRecordButtonClick!()
            }
        }
    }
    
    func isRecordingAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.bgView?.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            self.centerRoundView?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        }) { (isCom) in
        }
    }
    
    func startRecordingAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.bgView?.isHidden = false
            self.centerRoundView?.isHidden = false
            self.bgView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.centerRoundView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            
            self.afreshBtn?.isHidden = true
            self.ensureBtn?.isHidden = true
            self.afreshBtn?.center = Click_CenterPoint
            self.ensureBtn?.center = Click_CenterPoint
        }) { (isCom) in
            
        }
    }
    
    func endRecordingAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.bgView?.isHidden = true
            self.centerRoundView?.isHidden = true
            self.bgView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.centerRoundView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            
            self.afreshBtn?.isHidden = false
            self.ensureBtn?.isHidden = false
            self.afreshBtn?.center = CGPoint.init(x: Click_CenterPoint.x - 100, y: Click_CenterPoint.y)
            self.ensureBtn?.center = CGPoint.init(x: Click_CenterPoint.x + 100, y: Click_CenterPoint.y)
        }) { (isCom) in
            
        }
    }
    
    func addRecordView()  {

        
    }
    
    @objc func afreshBtnClick() {
        if (afreshButtonClick != nil) {
            afreshButtonClick!()
        }
    }
    
    @objc func ensureBtnClick() {
        if  (ensureButtonClick != nil){
            ensureButtonClick!()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
}


extension YXRecordView {
    
    func setUpUI()  {
        
        afreshBtn = UIButton.init(type: UIButtonType.custom)
        afreshBtn?.frame = CGRect.init(x: 0, y: 0, width: 60, height: 60)
        afreshBtn?.center = Click_CenterPoint
        afreshBtn?.isHidden = true
        afreshBtn?.setImage(UIImage.init(named: "hVideo_cancel"), for: UIControlState.normal)
        afreshBtn?.addTarget(self, action: #selector(afreshBtnClick), for: UIControlEvents.touchUpInside)
        self.addSubview(afreshBtn!)
        
        ensureBtn = UIButton.init(type: UIButtonType.custom)
        ensureBtn?.frame = CGRect.init(x: 0, y: 0, width: 60, height: 60)
        ensureBtn?.center = Click_CenterPoint
        ensureBtn?.isHidden = true
        ensureBtn?.setImage(UIImage.init(named: "hVideo_confirm"), for: UIControlState.normal)
        ensureBtn?.addTarget(self, action: #selector(ensureBtnClick), for: UIControlEvents.touchUpInside)
        self.addSubview(ensureBtn!)
        
//        ensureBtn = UIButton.init(type: UIButtonType.custom)
//        ensureBtn?.frame = CGRect.init(x: 0, y: 0, width: 60, height: 60)
//        ensureBtn?.center = Click_CenterPoint
//        ensureBtn?.isHidden = true
//        ensureBtn?.setImage(UIImage.init(named: "hVideo_confirm"), for: UIControlState.normal)
//        ensureBtn?.addTarget(self, action: #selector(ensureBtnClick), for: UIControlEvents.touchUpInside)
//        self.addSubview(ensureBtn!)
        
        bgView = YXRoundProgressView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        bgView?.backgroundColor = UIColor.init(red: 207/255.0, green: 202/255.0, blue: 198/255.0, alpha: 1)
        bgView?.layer.cornerRadius = (bgView?.frame.size.width)! / 2.0
        bgView?.clipsToBounds = true
        bgView?.center = Click_CenterPoint
        self.addSubview(bgView!)
        
        centerRoundView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
        centerRoundView?.backgroundColor = UIColor.white
        centerRoundView?.layer.cornerRadius = (centerRoundView?.frame.size.width)! / 2.0
        centerRoundView?.clipsToBounds = true
        centerRoundView?.center = Click_CenterPoint
        self.addSubview(centerRoundView!)
        
    }
}




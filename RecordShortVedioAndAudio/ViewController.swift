//
//  ViewController.swift
//  RecordShortVedioAndAudio
//
//  Created by admin on 2017/12/13.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    let RecordsTimeMax = 9  //录制最大时间
    let RecordsTimeMin = 0  //录制最小时间
    var keepTime:Int = 0
    var isVideoRecording:Bool = false
    var recordView:YXRecordView?
    
    var recordManager:YX_RecordManager?
    var player:YXAVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        recordManager = YX_RecordManager.init()
        
        //MARK:视图逻辑
        recordView = YXRecordView.init(frame: UIScreen.main.bounds)
        
        //点击录制
        recordView?.recordButtonClick = {[weak self] in
            self?.recordManager?.startSession()
            self?.startWriteRecord()
        }
        //点击离开时 停止录制
        recordView?.stopRecordButtonClick = {[weak self] in
            self?.recordManager?.stopSession()
            self?.endRecordConnection()
        }
        //重新录制
        recordView?.afreshButtonClick = {
            self.player?.isHidden = true
            self.player?.stopPlaye()
            self.recordView?.startRecordingAnimation()
        }
        //上传录制信息
        recordView?.ensureButtonClick = {
            print("开始上传")
            
        }
        self.view.insertSubview(recordView!, at: 0)
        //MARK:视频信息配置
        if (recordManager?.configureSession(vedioDevice: (recordManager?.frontVedioCaptureDevice)!))! {
            recordManager?.videoConnection?.videoOrientation =  (recordManager?.previewLayer.connection?.videoOrientation)!
            recordView?.layer.insertSublayer((recordManager?.previewLayer)!, at: 0)
        }
    }

    func startWriteRecord()  {
        keepTime = RecordsTimeMax
        self.perform(#selector(recordTiming), with: nil, afterDelay: 0)
    }
    
    @objc func recordTiming()  {
        keepTime -= 1
        if keepTime > 0 {
            if RecordsTimeMax - keepTime >= RecordsTimeMin && !isVideoRecording{
                self.recordView?.isRecordingAnimation()
                isVideoRecording = true
                self.recordView?.bgView?.timeMax = Double(keepTime)
            }
            self.perform(#selector(recordTiming), with: nil, afterDelay: 1)
        }
    }

    func endRecordConnection()  {
        self.recordView?.bgView?.clearProgress()
        self.recordView?.endRecordingAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


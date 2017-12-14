//
//  YXBaseRecordManager.swift
//  ShortVideoRecording
//
//  Created by admin on 2017/12/6.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit
import AVFoundation

typealias ResultSampleData = (_ sampleBuffer:CMSampleBuffer , _ output: AVCaptureOutput) -> Void

let resolutionX:Int =  1280 //视频分辨的宽
let resolutionY:Int =  720  //视频分辨的高

class YXBaseRecordManager: NSObject,AVCaptureVideoDataOutputSampleBufferDelegate{
    
    lazy var captureSession : AVCaptureSession = {
        let captureSession = AVCaptureSession.init()
        captureSession.beginConfiguration()
        return captureSession
    }()
    
    lazy var  vedioCaptureDevice : AVCaptureDevice = {
        var device : AVCaptureDevice?
        var captureDevices : NSArray
        if #available(iOS 10, *){
            let devicesIOS10 = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
            captureDevices = devicesIOS10.devices as NSArray
        }else{
            captureDevices = AVCaptureDevice.devices(for: AVMediaType.video) as NSArray
        }
        for  devices in captureDevices {
            if (devices as! AVCaptureDevice).position == .front{
                device = (devices as! AVCaptureDevice)
            }
        }
        return device!
    }()
    
    lazy var  audioCaptureDevice : AVCaptureDevice = {
        var device : AVCaptureDevice?
        var captureDevices : NSArray
        if #available(iOS 10, *){
            let devicesIOS10 = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInMicrophone], mediaType: AVMediaType.audio, position: AVCaptureDevice.Position.front)
            captureDevices = devicesIOS10.devices as NSArray
        }else{
            captureDevices = AVCaptureDevice.devices(for: AVMediaType.audio) as NSArray
        }
        for  devices in captureDevices {
            device = (devices as! AVCaptureDevice)
        }
        return device!
    }()
    
    lazy var queue : DispatchQueue = {
       let queue = DispatchQueue.init(label: "www.captureQue.com")
        return queue
    }()
    
    lazy var videoDataOutput : AVCaptureVideoDataOutput = {
       let videoDataOutput = AVCaptureVideoDataOutput.init()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
        let capSettings = NSDictionary.init(object: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, forKey: kCVPixelBufferPixelFormatTypeKey as! NSCopying)
        videoDataOutput.videoSettings = capSettings as! [String : Any]
       return videoDataOutput
    }()
    
    lazy var audioDataOutput:AVCaptureAudioDataOutput = {
       let audioDataOutput = AVCaptureAudioDataOutput.init()
        audioDataOutput.setSampleBufferDelegate((self as! AVCaptureAudioDataOutputSampleBufferDelegate), queue: queue)
        return audioDataOutput
    }()
    
    var activeVideoInput : AVCaptureDeviceInput?
    var videoConnection:AVCaptureConnection?
    var isCapturing:Bool?
    var resultSampleData:ResultSampleData?
    var recordEncoder:WCLRecordEncoder?
    var _channels:Int = 0 //音频通道
    var _samplerate:Float64 = 0//音频采样率

    override init() {
        super.init()
        
        isCapturing = false
    }
    
    func startSession()  {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func stopSession()  {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    //MARK:活跃摄像头配置
    func activeDeviceConfigure(device : AVCaptureDevice)  {
        
        do{
           try device.lockForConfiguration()
        }catch{
            
        }
        if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
            device.focusMode = AVCaptureDevice.FocusMode.autoFocus
        }
        if device.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance){
            device.whiteBalanceMode = AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance
        }
        if device.isSmoothAutoFocusSupported {
            device.isSmoothAutoFocusEnabled = true
        }
        device.unlockForConfiguration()
    }
    
    func configureConnection()  {
        for connection in self.videoDataOutput.connections {
            for port in connection.inputPorts{
                if port.mediaType == AVMediaType.video{
                    videoConnection = connection
                }
            }
        }
        if (videoConnection?.isVideoStabilizationSupported)!{
            let sysVer = Float(UIDevice.current.systemVersion)!
            if sysVer < 8.0 {
                videoConnection?.enablesVideoStabilizationWhenAvailable = true
            }else{
                videoConnection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
        }
    }
    
    //MARK:增加输出和输入
    //输出通道
    func configureOutPut() -> Bool {
        if self.captureSession.canAddOutput(self.videoDataOutput) {
            self.captureSession.addOutput(self.videoDataOutput)
        }else{
            return false
        }
        if self.captureSession.canAddOutput(self.audioDataOutput) {
            self.captureSession.addOutput(self.audioDataOutput)
        }else{
            return false
        }
        return true
    }
    
    //输入通道
    func configureActiveInPut(vedioDevice : AVCaptureDevice,audioDevice : AVCaptureDevice) -> Bool {
        do {
            let videoInput  = try? AVCaptureDeviceInput.init(device: vedioDevice)
            let audioInput  = try? AVCaptureDeviceInput.init(device: audioDevice)
            if (videoInput != nil && audioInput != nil) {
                if  self.captureSession.canAddInput(videoInput!)  {
                    self.captureSession.addInput(videoInput!)
                }
                if  self.captureSession.canAddInput(audioInput!){
                    self.captureSession.addInput(audioInput!)
                }
                self.activeVideoInput = videoInput
            }else{
                return false
            }
        } catch let printerError as Error {
            print(printerError)
            return false
        }
        return true
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //没有开始录制
        if !self.isCapturing! {
            return
        }
        if self.resultSampleData != nil {
            self.resultSampleData!(sampleBuffer,output)
        }
    }
    
    //MARK: 文件路径
    func getVideoCachePath()  {
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "\\videos"
        var isDir = ObjCBool(false)
        let fileManager = FileManager.default
        let isExisted  = fileManager.fileExists(atPath: filePath, isDirectory: &isDir)
        if !(isDir.boolValue == true && isExisted == true) {
               try? fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: [:])
        }
    }
    
    func getUploadFileName(_ name:String,type:String) -> String {
        let now = NSDate.init().timeIntervalSince1970
        let formatter = DateFormatter.init()
        formatter.dateFormat = "HHmmss"
        let nowDate = NSDate.init(timeIntervalSince1970: now)
        let timeStr  = formatter.string(from: nowDate as Date)
        return name + timeStr + type
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

//
//  YX_RecordManager.swift
//  RecordShortVedioAndAudio
//
//  Created by admin on 2017/12/14.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit

class YX_RecordManager: YXBaseRecordManager {

    var recordTimer:Timer?
    var isStartRecord:Bool = false
    
    override init() {
        super.init()
        
    }
    
    func startSession()  {
        isStartRecord = true
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func stopSession()  {
        isStartRecord = false
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func configureSession(vedioDevice : AVCaptureDevice) -> Bool {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        if !self.configureOutPut() || !self.configureActiveInPut(vedioDevice: self.frontVedioCaptureDevice, audioDevice: self.audioCaptureDevice){
            return false
        }
        self.configureConnection()
        self.activeDeviceConfigure(device: self.frontVedioCaptureDevice)
        self.captureSession.commitConfiguration()
        self.captureSession.startRunning()
        self.resultSampleData = {[weak self] (sampleBuffer,output) in
            self?.readyWriteFileData(sampleBuffer, output)
        }
        return true
    }
    
    func readyWriteFileData(_ sampleBuffer:CMSampleBuffer , _ output: AVCaptureOutput) -> Void {
        //开关是开始将视频写入文件
        if !isStartRecord {
            return
        }
        
        var isVideo : Bool = true
        if output == self.audioDataOutput {
            isVideo = false
        }
        if output == self.videoDataOutput {
            isVideo = true
        }
        
        if recordEncoder == nil && !isVideo {
            let fmt = CMSampleBufferGetFormatDescription(sampleBuffer)
            setAudioFormat(fmt!)
            //视频
            let videoName = getUploadFileName("video", type: "mp4")
            let videoStr = getVideoCachePath()
            let videoPath = videoStr.strings(byAppendingPaths: [videoName]).first
            recordEncoder = WCLRecordEncoder.init(path: videoPath, height: resolutionX, width: resolutionY, channels: Int32(_channels), samples: _samplerate)
            //音频
            let audioName = getUploadFileName("audio", type: "mp3")
            let audioStr = getVideoCachePath()
            let audioPath = audioStr.strings(byAppendingPaths: [audioName]).first
            recordEncoder = WCLRecordEncoder.init(path: audioPath, height: resolutionX, width: resolutionY, channels: Int32(_channels), samples: _samplerate)
        }
        recordEncoder?.encodeFrame(sampleBuffer, isVideo: isVideo)
    }
    
    /// 设置音频格式
    func setAudioFormat(_ fmt:CMFormatDescription) -> Void {
        let asbd:AudioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(fmt)!.pointee
        _samplerate = asbd.mSampleRate
        _channels = Int(asbd.mChannelsPerFrame)
    }

}

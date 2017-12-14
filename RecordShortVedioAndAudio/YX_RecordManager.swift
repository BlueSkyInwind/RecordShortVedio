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
    
    override init() {
        super.init()
        
    }
    
    func configureSession() -> Bool {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        if !self.configureOutPut() || !self.configureActiveInPut(vedioDevice: self.vedioCaptureDevice, audioDevice: self.audioCaptureDevice){
            return false
        }
        self.configureConnection()
        self.activeDeviceConfigure(device: self.vedioCaptureDevice)
        self.captureSession.commitConfiguration()
        self.captureSession.startRunning()
        self.resultSampleData = {[weak self] (sampleBuffer,output) in
            
        }
        return true
    }
    
    func readyWriteFileData(_ sampleBuffer:CMSampleBuffer , _ output: AVCaptureOutput) -> Void {
        var isVideo : Bool = true
        if output == self.audioDataOutput {
            isVideo = false
        }
        if output == self.vedioCaptureDevice {
            isVideo = true
        }
        if recordEncoder == nil && !isVideo {
            let fmt = CMSampleBufferGetFormatDescription(sampleBuffer)
            
            
            
        }
        
        
        recordEncoder?.encodeFrame(sampleBuffer, isVideo: isVideo)
    }
    
    func setAudioFormat(_ fmt:CMFormatDescription) -> Void {
        let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt)
        self._samplerate = asbd->mSampleRate
        self._channels = asbd->mChannelsPerFrame
    }
    
    
    
}

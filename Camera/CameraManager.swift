//
//  CameraManager.swift
//  Camera
//
//  Created by zeze on 16/8/23.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

protocol CameraManagerDelegate {
    func cameraManagerDidEndWriteFiles()
}
class CameraManager: NSObject {
    
    var previewLayer:AVCaptureVideoPreviewLayer!
    var delegate: CameraManagerDelegate?
    private var onrecord: Bool!
    var recording:Bool{
        return onrecord
    }
    
    private var currentCameraDevice:AVCaptureDevice?
    
    private var sessionQueue: dispatch_queue_t = dispatch_queue_create("com.jerry.session_queue", DISPATCH_QUEUE_SERIAL)
    
    private var session: AVCaptureSession!
    private var backCameraDevice: AVCaptureDevice?
    private var frontCameraDevice: AVCaptureDevice?
    private var audioMicDevice: AVCaptureDevice?
    
    
    
    private var stillCameraOutput: AVCaptureStillImageOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var audioOutput: AVCaptureAudioDataOutput?
    
   
     // MARK: - TODO write & save video files
    private var assetWrite: AVAssetWriter?
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var assetWriterAudioInput: AVAssetWriterInput?
    
    var currentSampleTime: CMTime?
    
    required init(delegate: CameraManagerDelegate) {
        self.delegate = delegate
        super.init()
        initializeSession()
        onrecord = false
    }
    
    func startRecording() {
        let url = NSFileManager.createVideoFileURL()
        if let videoUrl = url {
            do {
                assetWrite = try AVAssetWriter(URL: videoUrl, fileType: AVFileTypeQuickTimeMovie)
                
                let videoSetting: [String : AnyObject] = [
                    AVVideoCodecKey: AVVideoCodecH264,
                    AVVideoWidthKey: 320,
                    AVVideoHeightKey: 240,
                    AVVideoCompressionPropertiesKey: [
                        AVVideoPixelAspectRatioKey: [
                            AVVideoPixelAspectRatioHorizontalSpacingKey: 1,
                            AVVideoPixelAspectRatioVerticalSpacingKey: 1
                        ],
                        AVVideoMaxKeyFrameIntervalKey: 1,
                        AVVideoAverageBitRateKey: 1280000
                    ]
                ]
                
                assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSetting)
                assetWriterVideoInput?.expectsMediaDataInRealTime = true
                assetWriterVideoInput?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
                
                if ((assetWrite?.canAddInput(assetWriterVideoInput!)) != nil) {
                    assetWrite?.addInput(assetWriterVideoInput!)
                }
                
                let audioSetting: [String: AnyObject] = [
                    AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 22050
                ]
                
                assetWriterAudioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioSetting)
                if ((assetWrite?.canAddInput(assetWriterAudioInput!)) != nil) {
                    assetWrite?.addInput(assetWriterAudioInput!)
                }
             
                onrecord = true
            }catch _ {
                
            }
        }
        
    }
    
    
    func endRecording()  {
        if let assetWrite = assetWrite {
            if let assetWriterVideoInput = assetWriterVideoInput {
                assetWriterVideoInput.markAsFinished()
            }
            
            if let assetWriterAudioInput = assetWriterAudioInput {
                assetWriterAudioInput.markAsFinished()
            }
            self.onrecord = false
            assetWrite.finishWritingWithCompletionHandler({ 
                
            })
        }
        
        
    }
    
    
    func initializeSession() {
        session = AVCaptureSession()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        
        var authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        var requestAuthorVideo = false
        var requestAuthorAudio = false
        
        switch authorizationStatus {
        case .Authorized:
            requestAuthorVideo = true
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) in
                requestAuthorVideo = granted
            })
        case .Denied, .Restricted:
            print("Denied or Restricted requestAuthorVideo")
        }
        
        authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeAudio)
        switch authorizationStatus {
        case .Authorized:
            requestAuthorAudio = true
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio, completionHandler: { (granted: Bool) in
                requestAuthorAudio = granted
            })
        case .Denied, .Restricted:
            print("Denied or Restricted requestAuthorAudio")
            
        }
        
        if requestAuthorAudio && requestAuthorVideo {
            configureSession()
        }
        
    }
    
    func startRunning() {
        self.startRecording()
        performConfiguration { () -> Void in
            self.session.startRunning()
        }
    }

    func stopRunning() {
        self.endRecording()
        performConfiguration { () -> Void in
            self.session.stopRunning()
            
        }
    }
}

private extension CameraManager {
    
    func performConfiguration(block: (()-> Void)) {
        dispatch_async(sessionQueue) { () -> Void in
            block()
        }
    }
    
    func configureSession() {
        configureDeviceInput()
        configureOutput()
    }
    
    func configureDeviceInput() {
        performConfiguration { () -> Void in
            let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            for device in availableCameraDevices as! [AVCaptureDevice]{
                if device.position == .Back {
                    self.backCameraDevice = device
                }
                else if device.position == .Front {
                    self.frontCameraDevice = device
                }
            }
            
            self.currentCameraDevice = self.backCameraDevice
            
            
            let availableAudioDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)
            
            self.audioMicDevice = availableAudioDevices.first as? AVCaptureDevice
            
            
            do {
                let possibleCameraInput: AnyObject? = try AVCaptureDeviceInput(device: self.currentCameraDevice)
                if let backCameraInput = possibleCameraInput as? AVCaptureDeviceInput {
                    if self.session.canAddInput(backCameraInput){
                        self.session.addInput(backCameraInput)
                    }
                }
                
               
                let audioInput = try AVCaptureDeviceInput(device: self.audioMicDevice)
                if self.session.canAddInput(audioInput){
                    self.session.addInput(audioInput)
                }
            }catch{
                //catch error
            }
        }
    }
    
    func configureOutput() {
        videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey:  Int(kCVPixelFormatType_32BGRA)]
        
        videoOutput?.alwaysDiscardsLateVideoFrames = true
        videoOutput?.setSampleBufferDelegate(self, queue: self.sessionQueue)
        
        audioOutput = AVCaptureAudioDataOutput()
        audioOutput?.setSampleBufferDelegate(self, queue: self.sessionQueue)
    
        
        if self.session.canAddOutput(videoOutput){
            self.session.addOutput(videoOutput)
        }
        
        if self.session.canAddOutput(audioOutput) {
            self.session.addOutput(audioOutput)
        }
    }
    
    
}


extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate{
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if !onrecord {return}
        
        if assetWrite?.status != .Writing {
            let cst = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
            assetWrite?.startWriting()
            assetWrite?.startSessionAtSourceTime(cst)
        }
        
        if captureOutput == videoOutput {
            if let assetWriterVideoInput = self.assetWriterVideoInput where assetWriterVideoInput.readyForMoreMediaData {
                assetWriterVideoInput.appendSampleBuffer(sampleBuffer)
            }
        }
        else if captureOutput == audioOutput {
            if let assetWriterAudioInput = self.assetWriterAudioInput where assetWriterAudioInput.readyForMoreMediaData {
                assetWriterAudioInput.appendSampleBuffer(sampleBuffer)
            }
        }
 
    }

}





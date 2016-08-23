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
    var recording:Bool {
        get{
           return self.session.running
        }
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
    
    // MARK - TODO write & save video files
    
    private var assetWrite: AVAssetWriter?
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var assetWriterAudioInput: AVAssetWriterInput?
    
    var currentSampleTime: CMTime?
    
    required init(delegate: CameraManagerDelegate) {
        self.delegate = delegate
        super.init()
        initializeSession()
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
        performConfiguration { () -> Void in
            self.session.startRunning()
        }
    }

    func stopRunning() {
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
//        videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA as! AnyObject]
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
    
}





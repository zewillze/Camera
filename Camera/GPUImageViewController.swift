//
//  GPUImageViewController.swift
//  Camera
//
//  Created by zeze on 16/8/23.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation

class GPUImageViewController: UIViewController {
    @IBOutlet weak var renderView: RenderView!
    var camera:Camera!
    var filter:MissEtikateFilter!
    var isRecording = false
    var movieOutput:MovieOutput? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            var frontCameraDevice: AVCaptureDevice?
            let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            for device in availableCameraDevices as! [AVCaptureDevice]{
                if device.position == .Front {
                    frontCameraDevice = device
                    break
                }
            }
            camera = try Camera(sessionPreset: AVCaptureSessionPreset640x480, cameraDevice: frontCameraDevice)
//            camera = try Camera(sessionPreset:AVCaptureSessionPreset640x480)
        
            camera.runBenchmark = true
            filter = MissEtikateFilter()
            camera --> filter --> renderView
            camera.startCapture()
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        camera.stopCapture()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        camera = nil
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func capture(sender: AnyObject) {
        if (!isRecording) {
            self.isRecording = true
            (sender as! UIButton).titleLabel?.text = "Stop"
//            do {
            
//                let documentsDir = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain:.UserDomainMask, appropriateForURL:nil, create:true)
//                let fileURL = NSURL(string:"test.mp4", relativeToURL:documentsDir)!
//                do {
//                    try NSFileManager.defaultManager().removeItemAtURL(fileURL)
//                } catch {
//                }
//                
//                movieOutput = try MovieOutput(URL:fileURL, size:Size(width:480, height:640), liveVideo:true)
//                camera.audioEncodingTarget = movieOutput
//                filter --> movieOutput!
//                movieOutput!.startRecording()
                
//            } catch {
//                fatalError("Couldn't initialize movie, error: \(error)")
//            }
        } else {
            movieOutput?.finishRecording{
                self.isRecording = false
                dispatch_async(dispatch_get_main_queue()) {
                    (sender as! UIButton).titleLabel?.text = "Record"
                }
                self.camera.audioEncodingTarget = nil
                self.movieOutput = nil
            }
        }
    }


   
}

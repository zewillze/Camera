//
//  CaptureVideoViewController.swift
//  Camera
//
//  Created by zeze on 16/8/23.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import UIKit
 

class CaptureVideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var toggleButton: UIButton!
 
    var cameraManager: CameraManager!
    
    override func viewDidLoad() {
        cameraManager = CameraManager(delegate: self)
        let previewLayer = cameraManager.previewLayer
        previewLayer.frame = videoView.bounds
        videoView.layer.addSublayer(previewLayer)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let previewLayer = cameraManager.previewLayer
        previewLayer.frame = videoView.bounds
    }
    @IBAction func toggleHandle(sender: UIButton) {
        
        if cameraManager.recording {
            cameraManager.stopRunning()
        }
        else{
            cameraManager.startRunning()
        }
        let bgColor = cameraManager.recording ? UIColor.redColor(): UIColor.greenColor()
        sender.backgroundColor = bgColor
        
    }
    
}
extension CaptureVideoViewController: CameraManagerDelegate{
    func cameraManagerDidEndWriteFiles() {
        
    }
}
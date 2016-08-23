//
//  ViewController.swift
//  Camera
//
//  Created by zeze on 16/8/22.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import UIKit
import MobileCoreServices



class ViewController: UIViewController {
    
    
    var cameraOverlay = UIView()
    var camera: UIImagePickerController?
    override func viewDidLoad() {
        super.viewDidLoad()
     
        cameraOverlay.backgroundColor = UIColor.clearColor()
        
        cameraOverlay.frame = view.bounds
        let r = view.bounds
        let btnSize = CGSize(width: 80, height: 60)
        
        
        let startButton:UIButton = {
            let btn = UIButton(type: UIButtonType.Custom)
            btn.setTitle("Start", forState: .Normal)
            
            btn.addTarget(self, action: #selector(startVideoCapture), forControlEvents: .TouchUpInside)
            btn.frame = CGRect(x: r.origin.x + 40, y: r.size.height - 100, width: btnSize.width, height: btnSize.height)
            return btn
        }()
        
        cameraOverlay.addSubview(startButton)
        
        let stopButton:UIButton = {
            let btn = UIButton(type: .Custom)
            btn.setTitle("Stop", forState: .Normal)
            btn.addTarget(self, action: #selector(stopVideoCapture), forControlEvents: .TouchUpInside)
            btn.frame = CGRect(x: r.size.width - 40 - btnSize.width, y: r.size.height - 100, width: btnSize.width, height: btnSize.height)
            return btn
        }()
        
        cameraOverlay.addSubview(stopButton)
        
        
        let changeDevice:UIButton = {
            let btn = UIButton(type: .Custom)
            btn.setTitle("change", forState: .Normal)
            btn.addTarget(self, action: #selector(setCameraDevice), forControlEvents: .TouchUpInside)
            btn.frame = CGRect(x: r.size.width - 120, y: 40, width: btnSize.width, height: btnSize.height - 20)
            return btn
        }()
        
        cameraOverlay.addSubview(changeDevice)
        
        
        let dissButton:UIButton = {
            let btn = UIButton(type: .Custom)
            btn.setTitle("close", forState: .Normal)
            btn.addTarget(self, action: #selector(closeCamera), forControlEvents: .TouchUpInside)
            btn.frame = CGRect(x: 40, y: 40, width: btnSize.width, height: btnSize.height - 20)
            return btn
        }()
        
        cameraOverlay.addSubview(dissButton)
    }
    
    func closeCamera() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func startVideoCapture() {
        camera?.startVideoCapture()
    }
    
    func stopVideoCapture()  {
        camera?.stopVideoCapture()
    }
    
    
    func setCameraDevice()  {
        guard let c = camera else {return}
        
        switch c.cameraDevice {
        case .Front:
            guard UIImagePickerController.isCameraDeviceAvailable(.Rear) else {return}
            c.cameraDevice = .Rear
        case .Rear:
            guard UIImagePickerController.isCameraDeviceAvailable(.Front) else {return}
            c.cameraDevice = .Front
        }
    }
    
    @IBAction func pickController(sender: AnyObject) {
        
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else{
            if let b:UIButton = (sender as! UIButton) {
                b.setTitle("unAvailable", forState: .Normal)
            }
            return
        }
        guard ((UIImagePickerController.availableMediaTypesForSourceType(.Camera)?.contains(kUTTypeMovie as String)) != nil) else{
            return
        }
        
        
        camera = UIImagePickerController()
        camera?.sourceType = .Camera
        camera?.mediaTypes = [kUTTypeMovie as String]
        camera?.delegate = self
        camera?.videoQuality = .TypeHigh
        
        camera?.showsCameraControls = false
        camera?.cameraOverlayView = cameraOverlay
        
        self.presentViewController(camera!, animated: true, completion: nil)
 
    }
    
    
    @IBAction func showAVCapture(sender: AnyObject) {
        self.performSegueWithIdentifier("showAVCapture", sender: self)
    }
  
    @IBAction func showGPUImageView(sender: UIButton) {
        self.performSegueWithIdentifier("showGPUImageView", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
    }
    
    
    
}
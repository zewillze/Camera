//
//  AVCaptureViewController.swift
//  Camera
//
//  Created by zeze on 16/8/23.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import UIKit
import AVFoundation

class AVCaptureViewController: UIViewController {

 
    @IBOutlet weak var filesContainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fileContain" {
            let fc = segue.destinationViewController as! FilesViewControllers
            fc.delegate = self
        }
        
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AVCaptureViewController: FileSelectDelegate {
    func didSelected(pathURL: NSURL) {
        let pc = PlayerController()
        pc.pathURL = pathURL
        self.navigationController?.pushViewController(pc, animated: true)
    }
}

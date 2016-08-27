//
//  PlayerController.swift
//  Camera
//
//  Created by zeze on 16/8/27.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class PlayerController: UIViewController {
    
    var pathURL:NSURL?
    
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    let invisibleButton = UIButton()
    var timeObserver: AnyObject!
    let timeRemainingLabel = UILabel()
    let seekSlider = UISlider()
    var playerRateBeforeSeek: Float = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blackColor()
        
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer);
        view.layer.insertSublayer(avPlayerLayer, atIndex: 0)
        
        view.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: #selector(invisibleButtonTapped), forControlEvents: .TouchUpInside)
        
        
        view.addSubview(timeRemainingLabel)
        
        view.addSubview(seekSlider)
        
        seekSlider.addTarget(self, action: #selector(sliderBeganTracking), forControlEvents: .TouchDown)
        
        seekSlider.addTarget(self, action: #selector(sliderEndedTracking), forControlEvents: [.TouchUpInside, .TouchUpOutside])
        
        seekSlider.addTarget(self, action: #selector(sliderValueChanged), forControlEvents: .ValueChanged)
        
  
      
        if let pathURL = pathURL {
            let playItem = AVPlayerItem(URL: pathURL)
            avPlayer.replaceCurrentItemWithPlayerItem(playItem)
            
            let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
            timeObserver = avPlayer.addPeriodicTimeObserverForInterval(timeInterval, queue: dispatch_get_main_queue(), usingBlock: { (elapsedTime: CMTime) -> Void in
                print("elapsedTime now : \(CMTimeGetSeconds(elapsedTime))")
                self.observeTime(elapsedTime)
            })
        }
 
    }
    
    
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
    }
    
    
    func sliderEndedTracking(slider: UISlider)  {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        avPlayer.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) in
            if self.playerRateBeforeSeek > 0{
                self.avPlayer.play()
            }
        }
    }
    
    
    func sliderValueChanged(slider: UISlider)  {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    private func updateTimeLabel(elapsedTime elapsedTime: Float64, duration: Float64){
        let timeRemaining: Float64 = CMTimeGetSeconds(avPlayer.currentItem!.duration) - elapsedTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    private func observeTime(t: CMTime){
        let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        if isfinite(duration){
            let elapsedTime = CMTimeGetSeconds(t)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }
    
    deinit{
        avPlayer.removeTimeObserver(timeObserver)
    }
    
    func invisibleButtonTapped(){
        let playIsPlaying = avPlayer.rate > 0
        if playIsPlaying {
            avPlayer.pause()
        }
        else{
            avPlayer.play()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avPlayerLayer.frame = view.bounds
        invisibleButton.frame = view.bounds
        
        let controlsWidth: CGFloat = 60
        let controlsHeight: CGFloat = 30
        let controlsY: CGFloat = view.bounds.size.height - controlsHeight
        let r = CGRect(x: 5, y: controlsY, width: controlsWidth, height: controlsHeight)
        
        
        timeRemainingLabel.frame = r
        timeRemainingLabel.textColor = .whiteColor()
        
        
        seekSlider.frame = CGRect(x: r.origin.x + r.size.width , y: controlsY, width: view.bounds.size.width - controlsWidth, height: controlsHeight)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

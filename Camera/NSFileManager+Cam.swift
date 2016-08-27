//
//  NSFileManager+Cam.swift
//  Camera
//
//  Created by zeze on 16/8/27.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import Foundation

extension NSFileManager {
    
    class func cachesURL() -> NSURL{
        return try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    }
    
    class func videoCachesURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let videoCachesURL = cachesURL().URLByAppendingPathComponent("video_caches", isDirectory: true)
        
        do{
            try fileManager.createDirectoryAtURL(videoCachesURL, withIntermediateDirectories: true, attributes: nil)
            return videoCachesURL
        }catch _ {
            
        }
        return nil
    }
    
    class func createVideoFileURL() -> NSURL?{
        let currentDate = NSDate()
        let formate = NSDateFormatter()
        formate.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let fileName = formate.stringFromDate(currentDate)
        if let filePath = videoCachesURL()?.URLByAppendingPathComponent("\(fileName).mp4") {
            return filePath
        }
        return nil
    }
    
    class func getVideoFilesPathLists() -> [String]{
        if let paths = NSFileManager.defaultManager().subpathsAtPath((videoCachesURL()?.path)!){
            print(paths)
            return paths
        }
        
        return []
    }
}

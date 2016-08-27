//
//  FilesViewControllers.swift
//  Camera
//
//  Created by zeze on 16/8/23.
//  Copyright © 2016年 zeWill. All rights reserved.
//

import UIKit

let identifier = "VideoFileCellIdentifier"

protocol FileSelectDelegate {
    func didSelected(pathURL: NSURL);
}

class FilesViewControllers: UIViewController {
    
    @IBOutlet weak var tbView: UITableView!
    var datas:[String]?
    var delegate: FileSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datas = NSFileManager.getVideoFilesPathLists()
        self.tbView.reloadData()
        self.tbView.tableFooterView = UIView()
    }
    
}

extension FilesViewControllers: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        cell?.textLabel?.text = datas![indexPath.row]
        return cell!
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let name = datas![indexPath.row]
        let url = NSFileManager.videoCachesURL()?.URLByAppendingPathComponent(name)
        if let delegate = delegate{
            delegate.didSelected(url!)
        }
    }
}
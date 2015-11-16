//
//  ViewController.swift
//  BXLoadMoreControl
//
//  Created by banxi1988 on 11/16/2015.
//  Copyright (c) 2015 banxi1988. All rights reserved.
//

import UIKit
import BXLoadMoreControl

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let control = BXLoadMoreControl()
        self.bx_loadMoreControl = control
        control.onLoadingHandler = {
            NSLog("onLoadingHandler called")
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)){
                sleep(3)
                dispatch_async(dispatch_get_main_queue()){
                    control.endLoading()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = "Titlte \(indexPath.row + 1)"
        return cell
    }

}


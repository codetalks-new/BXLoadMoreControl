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

    var itemCount = 20
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let control = BXLoadMoreControl()
        self.bx_loadMoreControl = control
        control.onLoadingHandler = {
            NSLog("onLoadingHandler called")
          DispatchQueue.global(qos:DispatchQoS.QoSClass.userInitiated).async(){
                sleep(3)
            DispatchQueue.main.async(){
                   self.itemCount = 30
                    control.endLoading()
                  self.tableView.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Titlte \(indexPath.row + 1)"
        return cell
    }

}


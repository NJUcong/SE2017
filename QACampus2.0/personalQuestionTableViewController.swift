//
//  personalQuestionTableViewController.swift
//  QACampus2.0
//
//  Created by NJUcong on 2017/7/11.
//  Copyright © 2017年 Demons. All rights reserved.
//

import UIKit

class personalQuestionTableViewController: collectQuestionTableViewController {

    lazy var results:[Result] = {
        return []
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
//    func cancel(sender:Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
}

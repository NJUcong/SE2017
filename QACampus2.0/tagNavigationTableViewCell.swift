//
//  tagNavigationTableViewCell.swift
//  QACampus2.0
//
//  Created by NJUcong on 2017/7/10.
//  Copyright © 2017年 Demons. All rights reserved.
//

import UIKit

class tagNavigationTableViewCell: UITableViewCell {

    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var num: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  result.swift
//  QACampus2.0
//
//  Created by 王乙飞 on 2017/7/11.
//  Copyright © 2017年 Demons. All rights reserved.
//

import UIKit

class Result {
    var id:Int=0
    var icon:UIImage
    var name:String=""
    var time:String=""
    var title:String=""
    var desc:String=""
    
    init(id:Int, name:String, time:String, title:String, desc:String){
        self.id = id
        self.icon = UIImage(named:"no.1")!
        self.name = name
        self.time = time
        self.title = title
        self.desc = desc
    }
    
    public func setIcon(icon:UIImage){
        self.icon=icon
    }
}

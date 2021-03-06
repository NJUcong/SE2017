//
//  studioHomeTopicTableViewController.swift
//  QACampus2.0
//
//  Created by NJUcong on 2017/7/4.
//  Copyright © 2017年 Demons. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class studioHomeTopicTableViewController: UITableViewController {

    lazy var itemData:[Result] = {
        return []
    }()
    
    lazy var avators:[Int:UIImage] = {
        return [:]
    }()
    
    lazy var backgrounds:[Int:UIImage] = {
        return [:]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        
        self.view.backgroundColor = sectionHeaderColor
        self.tableView.backgroundColor = sectionHeaderColor

        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int){
        view.tintColor = subTitleBorderColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectQuestion", for: indexPath) as! collectQuestionTableViewCell
        let result:Result = itemData[indexPath.row]
        cell.title.text = result.title
        cell.date.text = result.time
        cell.name.text = result.name
        cell.introduction.text = result.desc
        cell.avator.image = (avators[result.id] != nil) ? avators[result.id]:UIImage(named: "no.1")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TopicDetail.id = itemData[indexPath.row].id
        let topicDetailView = UIStoryboard(name: "TopicDetail", bundle: nil).instantiateInitialViewController()
        self.present(topicDetailView!, animated: true, completion: nil)
    }
    
}

extension studioHomeTopicTableViewController{
    
    func initData() {
        let headers:HTTPHeaders = [
            "Authorization": userAuthorization
        ]
        Alamofire.request("https://\(root):8443/topic-service/topic/\(LocalStudio.id)" ,method: .get,headers: headers).responseJSON { response in
            
            // response serialization result
            if response.result.value != nil {
                var json = JSON(response.result.value)
                let list: Array<JSON> = json["content"].arrayValue
                
                for json in list {
                    let topic_id:Int = json["id"].int!
                    let title = json["title"].string
                    let writer_id:Int = json["writer"].int!
                    let introduction = json["content"].string
                    //时间戳／ms转为/s
                    let dateStamp = json["date"].intValue/1000
                    // 时间戳转字符串
                    let date:String = date2String(dateStamp: dateStamp)
                    
                    let path:String = "user/\(writer_id)"
                    
                    //请求客户端的文件路径下的文件
                    Alamofire.request(storageRoot+path, method: .get).responseJSON { response in
                        if let json = response.result.value {
                            print(json)
                            let pictures:[String] = json as! [String]
                            let pic_path = path.appending("/" + pictures[0])
                            
                            //获取文件
                            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                let fileURL = documentsURL.appendingPathComponent(pic_path)
                                
                                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                            }
                            Alamofire.download(uploadRoot+pic_path, to: destination).response { response in
                                
                                if response.error == nil, let imagePath = response.destinationURL?.path {
                                    self.avators[topic_id] = getPicture(pic_path)
                                    self.reload()
                                }
                            }
                        }
                    }
                    
                    //根据id获取writer的姓名
                    Alamofire.request("https://\(root):8443/owner-service/owners/\(writer_id)" ,method: .get,headers: headers).responseJSON { response in
                        
                        var json = JSON(response.result.value!)
                        let name:String = json["display_name"].string!
                        let id:Int = json["id"].int!
                        
                        let result = Result(id:topic_id, name:name, time:date ,title: title!,desc:introduction! )
                        self.itemData.append(result)
                        self.reload()
                    }
                    
                }
            }
        }

    }
    
    func reload() {
        self.tableView.reloadData()
    }
}

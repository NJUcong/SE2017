//
//  DetailViewController.swift
//  QACampus2.0
//
//  Created by Eric Wen on 2017/6/2.
//  Copyright © 2017年 Demons. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class UserHotDetailViewController: UITableViewController {
    
    var answerList: [Answer] = []
    var favBtn: UIBarButtonItem? = nil
    var ansBtn: UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        requestData()
        
        tellIfInStudio()
        
        favBtn = UIBarButtonItem(title: "收藏", style: .plain, target: self, action: #selector(addToFav))
        ansBtn = UIBarButtonItem(title: "回答", style: .plain, target: self, action: #selector(addAnswer))
        
        self.navigationItem.rightBarButtonItems = [
            favBtn!,
            ansBtn!
        ]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"返回", style: .plain, target: self, action: #selector(cancel))
    }
    
    func addAnswer() {
        Question.question_id = Detail.questionId
        performSegue(withIdentifier: "ToAnswer", sender: nil)
    }
    
    func addToFav() {
        DispatchQueue.global().async {
            authentication()
            let headers: HTTPHeaders = [
                "Authorization": userAuthorization,
                "question": String(Detail.questionId)
            ]
            Alamofire.request("https://\(root):8443/owner-service/owners/\(User.localUserId!)/question/collect", method: .post, headers: headers).responseJSON { response in
                if let jsonData = response.result.value {
                    let ac = UIAlertController(title: "收藏成功", message: nil, preferredStyle: .alert)
                    self.present(ac, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: (UInt64)(2 * NSEC_PER_SEC))) {
                        ac.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    func getUserId(_ askerId: Int, _ action: @escaping (String)->Void) {
        DispatchQueue.global().async {
            authentication()
            let headers: HTTPHeaders = [
                "Authorization": userAuthorization
            ]
            Alamofire.request("https://\(root):8443/owner-service/owners/\(askerId)", method: .get, headers: headers).responseJSON { response in
                if let jsonData = response.result.value {
                    let json = JSON(jsonData)
                    let name = json["display_name"].stringValue
                    action(name)
                }
            }
        }
    }
    
    func tellIfInStudio() {
        DispatchQueue.global().async {
            authentication()
            let headers: HTTPHeaders = [
                "Authorization": userAuthorization
            ]
            Alamofire.request("https://\(root):8443/owner-service/owners/\(User.localUserId!)", method: .get, headers: headers).responseJSON { response in
                if let jsonData = response.result.value {
                    let json = JSON(jsonData)
                    let studioList = json["studio"].arrayValue
                    self.ansBtn!.isEnabled = false
                    for studio in studioList {
                        let studioId = studio.intValue
                        if studioId == Detail.studioId {
                            self.ansBtn!.isEnabled = true
                            break
                        }
                    }
                }
            }
        }
    }
    
    func requestData() {
        DispatchQueue.global().async {
            authentication()
            let headers: HTTPHeaders = [
                "Authorization": userAuthorization
            ]
            Alamofire.request("https://\(root):8443/qa-service/questions/\(Detail.questionId)", method: .get, headers: headers).responseJSON { response in
                if let jsonData = response.result.value {
                    let json = JSON(jsonData)
                    print(json)
                    Detail.questionId = json["id"].intValue
                    Detail.askerId = json["asker"].intValue
                    Detail.likeCount = json["thumb"].intValue
                    Detail.questionTitle = json["question"].stringValue
                    Detail.questionDetail = json["describtion"].stringValue
                    Detail.studioId = json["studio"].intValue
                    self.tellIfInStudio()
                    Detail.questionDetailAttr = nil
                    
                    // TODO: get data
                    let path:String = "question/\(Detail.questionId)/\(Detail.askerId))/question"
                    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let fileURL = documentsURL.appendingPathComponent(path)
                        
                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    
                    Alamofire.download(uploadRoot+path, to: destination).response { response in
                        
                        if response.error == nil {
                            let data = getQuestion(path)
                            //异步加载 使用data应在这个上下文里面
                        }        
                    }
                    // Detail.questionDetailAttr = NSKeyedUnarchiver.unarchiveObject(with: data) as NSAttributedString
                    Detail.questionDate = Date(timeIntervalSince1970: json["date"].doubleValue / 1000)
                    self.getUserId(Detail.askerId) { str in
                        Detail.askerAlias = str
                    }
                    let answer = json["answer"].arrayValue
                    for ans in answer {
                        let ansId = ans["answerId"].intValue
                        let ansDetail = ans["details"].stringValue
                        let ansDate = ans["date"].doubleValue / 1000
                        var answer = Answer(id: ansId, str: ansDetail, date: Date(timeIntervalSince1970: ansDate))
                        answer.answererId = ans["answerer"].intValue
                        self.getUserId(answer.answererId) { str in
                            answer.answererAlias = str
                        }
                        self.answerList.append(answer)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return answerList.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: UserHotDetailContentCell = self.tableView.dequeueReusableCell(withIdentifier: "TitleDetailCell") as! UserHotDetailContentCell
            cell.userId = Detail.askerId
            cell.titleLabel.text = Detail.questionTitle
            cell.detailLabel.text = Detail.questionDetail
            if let attrText = Detail.questionDetailAttr {
                cell.detailLabel.attributedText = attrText
            }
            cell.likeCountLabel.text = String(Detail.likeCount)
            cell.timeLabel.text = DateFormatter.localizedString(from: Detail.questionDate, dateStyle: .short, timeStyle: .medium)
            cell.askerButton.setTitle(Detail.askerAlias, for: .normal)
            cell.askerButton.sizeToFit()
            cell.titleLabel.sizeToFit()
            cell.detailLabel.sizeToFit()
            cell.likeCountLabel.sizeToFit()
            cell.timeLabel.sizeToFit()
            cell.controller = self
            return cell
        }
        else {
            /*let cell: UserHotDetailCommentCell = self.tableView.dequeueReusableCell(withIdentifier: "commentCell") as! UserHotDetailCommentCell
            cell.commentLabel.text = String(repeating: "这是评论", count: 100)
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            //cell.timeLabel.text = formatter.string(from: Date())
            cell.timeLabel.text = ""
            cell.userIdButton.sizeToFit()
            cell.timeLabel.sizeToFit()
            cell.commentLabel.sizeToFit()
            return cell*/
            let cell: UserHotDetailAnswerCell = self.tableView.dequeueReusableCell(withIdentifier: "AnswerCell") as! UserHotDetailAnswerCell
            cell.userId = answerList[indexPath.row].answererId
            cell.answerLabel.text = answerList[indexPath.row].str
            cell.timeLabel.text = DateFormatter.localizedString(from: answerList[indexPath.row].date, dateStyle: .short, timeStyle: .medium)
            cell.answererButton.setTitle(answerList[indexPath.row].answererAlias, for: .normal)
            cell.answererButton.sizeToFit()
            cell.answerLabel.sizeToFit()
            cell.timeLabel.sizeToFit()
            return cell
        }
    }
    
    func configLabelSize(_ label: UILabel) -> CGSize {
        return CGSize()
    }
    
    func like(_ questionId: Int) {
        DispatchQueue.global().async {
            authentication()
            let headers: HTTPHeaders = [
                "Authorization": userAuthorization,
                "question": String(Detail.questionId)
            ]
            Alamofire.request("https://\(root):8443/owner-service/owners/\(User.localUserId!)/question/thumb", method: .post, headers: headers).responseJSON { response in
                if let jsonData = response.result.value {
                    let ac = UIAlertController(title: "点赞成功", message: nil, preferredStyle: .alert)
                    self.present(ac, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: (UInt64)(2 * NSEC_PER_SEC))) {
                        ac.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}

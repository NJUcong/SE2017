import  UIKit
import  Alamofire
import  SwiftyJSON


class QuestionEditorController: TitleDetailEditorController {
    
    @IBOutlet weak var titleViewRef: UITextField!
    @IBOutlet weak var detailViewRef: UITextView!
    
    override func setTitleViewAndDetailViewReference() {
        self.titleView = titleViewRef
        self.detailView = detailViewRef
    }
    
    override func setDetailViewInfo() {
        self.detailViewPlaceholder = "详细描述你的问题"
    }
    
    override func supportRichText() -> Bool {
        return true //支持富文本吗
    }
    
    override func setType() {
        self.isQuestion = true
    }
    
    override func doneClicked() {
       
        super.doneClicked()
        let detailData = NSKeyedArchiver.archivedData(withRootObject: detailView?.attributedText!)
        sampleData = detailData
        let titleText:String = (titleView?.text)!
        let detailText:String = (detailView?.text)!
    
        let length:Int = detailText.length
        let index_length:Int = min(length,50)
        let index = detailText.index(detailText.startIndex, offsetBy: index_length)
        let describtion = detailText.substring(to: index)
        
        let userDefault = UserDefaults.standard
      
        
        let headers:HTTPHeaders = [
            "Authorization": userAuthorization
        ]
        let parameters:Parameters = [
            "que": titleText,
            "des": describtion,
            "asker": User.localUserId,
            "money": 0,
            "studio": LocalStudio.id
        ]
        
        Alamofire.request("https://\(root):8443/qa-service/questions",method: .post, parameters:parameters,headers:headers).responseJSON { response in
           
            debugPrint(response)
            if response.result.value != nil {
                // response serialization result
                var json = JSON(response.result.value!)
                print(json)
                Question.question_id = json.intValue
            }
        
            let path:String = "question/\(Question.question_id)/\(User.localUserId!)"
//         let path:String = "question/150/\(User.localUserId!)"
            userDefault.set(detailData, forKey: path)
            prepareFile(path, destination: uploadRoot+path)
        }
        self.dismiss(animated: true, completion: nil)

    }
    
  
    
    override func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}

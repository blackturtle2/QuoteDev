//
//  BoardDevDetailCommentCell.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 10. 13..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase

class BoardDevDetailCommentCell: UITableViewCell {

    @IBOutlet weak var userNickNameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var commentCreateAtLabel: UILabel!
    @IBOutlet weak var commentLikeLabel: UILabel!
    var commentUID: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeBtnTouched(_ sender: UIButton){
        guard let user_uid = UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) else{return}
        let reference = Database.database().reference()
        
        reference.child("board_comment_like").child(commentUID).runTransactionBlock({ [unowned self] (currentLikeData) -> TransactionResult in
            // #. 코드 리펙토링 필요 간결하게 구성할것. 일단은 구동먼저
            
            // boardUID값 하위에 키값으로 useruid를 가지고 생성일을 value에 할당한 딕셔너리 구조로 데이터 생성
            var likeData: [String: Any] = [:]
            print(currentLikeData.children.allObjects)
            print(currentLikeData.childData(byAppendingPath: user_uid))
            if currentLikeData.hasChildren(){
                //                print("똑같은 노드에 값존재 한단다 :/",user_uid)
                likeData = currentLikeData.value as! [String:Any]
                print(likeData)
                let flag = likeData.contains(where: { (key,value) -> Bool in
                    return key == user_uid
                })

                if flag {
                    likeData.removeValue(forKey: user_uid)
                }else{
                    likeData[user_uid] = ServerValue.timestamp()


                }
            }else{
                likeData[user_uid] = ServerValue.timestamp()


            }
            
            currentLikeData.value = likeData
            
            DispatchQueue.main.async {
                self.commentLikeLabel.text = "\(currentLikeData.childrenCount)"
            }
            return TransactionResult.success(withValue: currentLikeData)
        }) { (error, commit, dataSnapShot) in
            
        }
    }

}

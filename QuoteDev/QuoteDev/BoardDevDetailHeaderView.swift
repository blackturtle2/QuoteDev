//
//  BoardDevDetailHeaderView.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 10. 16..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase

class BoardDevDetailHeaderView: UIView {
    
    @IBOutlet weak var boardCountLabel: UILabel!
    @IBOutlet weak var boardWriterLabel: UILabel!
    @IBOutlet weak var boardCotentsLabel: UILabel!
    @IBOutlet weak var boardCreateAtLabel: UILabel!
    
    @IBOutlet weak var boardLikeBtn: UIButton!
    @IBOutlet weak var boardLikeCountLabel: UILabel!
    @IBOutlet weak var boardReqCountLabel: UILabel!
    
    @IBOutlet weak var boardImgView: UIImageView!
    
    var reference: DatabaseReference!
    var boardUID: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("이미지뷰 가로길이://",boardImgView.frame.size.width)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print("헤더뷰 layouSubView")
        
        
    }
    
    // 좋아요 버튼 클릭
    // 좋아요 클릭한 데이터값이 존재 하면 숫자가 더해지고 한번 누른 상태에서 다시 누르면 감소해야한다
    @IBAction func likeBtnTouched(_ sender: UIButton){
        
        guard let user_uid = UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) else{return}
        reference = Database.database().reference()

        reference.child("board_like").child(boardUID).runTransactionBlock({ [unowned self] (currentLikeData) -> TransactionResult in
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
                self.boardLikeCountLabel.text = "\(currentLikeData.childrenCount)"
            }
            return TransactionResult.success(withValue: currentLikeData)
        }) { (error, commit, dataSnapShot) in
            
        }
        
    }
    
}

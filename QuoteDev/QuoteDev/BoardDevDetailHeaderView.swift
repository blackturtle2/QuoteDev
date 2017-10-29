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
        
        guard let user_uid = UserDefaults.standard.string(forKey: Constants.userDefaults_Uid) else{return}
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
            /*
            print("SELF.USERUID://,", user_uid)
            // 1. currentLikeData에 값이 있는지 판다.
            if var likeData = currentLikeData.value as? [String:Any]{
                
                // 2. likeData에 키값으로 사용자 useruid를 포함하는지 비교
                if likeData.contains(where: { (key,value) -> Bool in
                    return key == user_uid
                }) {
                    print(likeData)
                    likeData.removeValue(forKey: user_uid)
                    print(likeData)
                    currentLikeData.value = likeData
                    
                }else{ // 3. 포함하지 않는 경우
                    //boardLikeData.updateValue(ServerValue.timestamp(), forKey: user_uid)
                    // 생성한 데이터를 다시 currentLikeData에 할당
                    currentLikeData.value = likeData.updateValue(ServerValue.timestamp(), forKey: user_uid)
                    // currentLikeData.setValue(ServerValue.timestamp(), forKey: user_uid)
                }
                
                
            }
            else{ // 4. currentLikeData에 값이 없을 경우(게시글에 좋아요 한 데이터가 존재 하지 않는 경우 - 최초)
                var boardLikeData: [String:Any] = [:]
                boardLikeData.updateValue(ServerValue.timestamp(), forKey: user_uid)
                // 생성한 데이터를 다시 currentLikeData에 할당
                currentLikeData.value = boardLikeData
                
            }
           
            print("파이어베이스 서버시간://", ServerValue.timestamp())
            // 리턴이 필수!
            DispatchQueue.main.async {
                self.boardLikeCountLabel.text = "\(currentLikeData.childrenCount)"
            }
 */
            DispatchQueue.main.async {
                self.boardLikeCountLabel.text = "\(currentLikeData.childrenCount)"
            }
            return TransactionResult.success(withValue: currentLikeData)
        }) { (error, commit, dataSnapShot) in
            
        }
        
    }
    
}

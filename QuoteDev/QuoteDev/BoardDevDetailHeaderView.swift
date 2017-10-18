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
    var userUID: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        print("이미지뷰 가로길이://",boardImgView.frame.size.width)
        boardImgView.layer.cornerRadius = 20
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("헤더뷰 layouSubView")
        
        
    }
    
    // 좋아요 버튼 클릭
    // 좋아요 클릭한 데이터값이 존재 하면 숫자가 더해지고 한번 누른 상태에서 다시 누르면 감소해야한다
    @IBAction func likeBtnTouched(_ sender: UIButton){
        let likeData: [String:String] = ["user_uid": userUID]
        reference = Database.database().reference()
// 1.배열구조
//        reference.child("board_like").child(boardUID).observeSingleEvent(of: .value, with: { (dataSnap) in
//            var likeCount = 0
//            if dataSnap.exists() {
//                likeCount = Int(dataSnap.childrenCount)
//            }
//        self.reference.child("board_like").child(self.boardUID).child(likeCount.description).setValue(likeData)
//
//        }) { (error) in
//
//        }

// 2. childAutoById구조
        
//        reference.child("board_like").child(boardUID).childByAutoId().setValue(likeData)
//
//        print(reference.child("board_like").child(boardUID).childByAutoId().key)
//
//        reference.child("board_like").child(boardUID).childByAutoId().child("user_uid").observeSingleEvent(of: .value, with: { (dataSanp) in
//
//        }) { (error) in
//
//        }
        
        reference.child("board_like").child(boardUID).runTransactionBlock({ (currentLikeData) -> TransactionResult in
            print(currentLikeData.value)
            
            var boardLikeData: [String:Any] = [:]
            boardLikeData.updateValue(ServerValue.timestamp(), forKey: self.userUID)
            print(boardLikeData)
            currentLikeData.value = boardLikeData
            return TransactionResult.success(withValue: currentLikeData)
        }) { (error, commit, dataSnapShot) in
            
        }
        
    }
    
}

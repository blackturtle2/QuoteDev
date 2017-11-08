//
//  QuoteCommentTableViewCell.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 10. 28..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase

class QuoteCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelCommentKeyID: UILabel!
    @IBOutlet weak var labelCommentWriter: UILabel!
    @IBOutlet weak var labelCommentText: UILabel!
    @IBOutlet weak var labelCommentCreatedDate: UILabel!
    @IBOutlet weak var buttonCommentLikeCount: UIButton!
    
    var todayQuoteID: String? // 명언 ID
    var commentKeyID: String? // 댓글 Key ID
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: 댓글 좋아요 버튼 액션
    @IBAction func buttonCommentLikeAction(_ sender: UIButton) {
        print("///// buttonCommentLikeAction- 5234")
        
        guard let realCommentKeyID = self.commentKeyID else { return }
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        Database.database().reference().child(Constants.firebaseQuoteCommentsLikes).child(realTodayQuoteID).child(realCommentKeyID).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            
            // 해당 명언 댓글에 대해 좋아요 데이터가 있는지 조회합니다.
            if snapshot.exists() { // snapshot이 있을 경우, 바로 좋아요 기능 작동.
                self.postShowLikeQuoteDB()
            }else {
                let dicInitData:[String:Any] = ["use":true] // 이니셜 데이터.
                Database.database().reference().child(Constants.firebaseQuoteCommentsLikes).child(realTodayQuoteID).child(realCommentKeyID).setValue(dicInitData) // realCommentKeyID의 노드 생성.
                self.postShowLikeQuoteDB() // 좋아요 기능 작동.
            }
            
        }) { (error) in
            print("///// error- 5234: \n", error.localizedDescription)
        }

    }
    
    // MARK: 댓글 좋아요 카운트 버튼 액션
    @IBAction func buttonCommentLikeCountAction(_ sender: UIButton) {
        print("///// buttonCommentLikeCountAction- 5223")
        
        self.buttonCommentLikeAction(buttonCommentLikeCount) // 댓글 좋아요 버튼과 같은 액션으로 작동합니다.
    }
    
    // MARK: 좋아요 추가/취소 구현
    // realTodayQuoteID 노드가 있다는 전제로 좋아요 기능이 작동됩니다.
    func postShowLikeQuoteDB() {
        guard let realUid = Auth.auth().currentUser?.uid else { return }
        guard let realCommentKeyID = self.commentKeyID else { return }
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        Database.database().reference().child(Constants.firebaseQuoteCommentsLikes).child(realTodayQuoteID).child(realCommentKeyID).runTransactionBlock({[unowned self] (currentData) -> TransactionResult in
            print("///// try runTransactionBlock- 5234")
            
            if var post = currentData.value as? [String : AnyObject] {
                var likes = post[Constants.firebaseQuoteCommentsLikesData] as? [String : Bool] ?? [:]
                var likeCount = post[Constants.firebaseQuoteCommentsLikesCount] as? Int ?? 0
                
                if let _ = likes[realUid] {
                    // 좋아요 취소
                    likeCount -= 1
                    likes.removeValue(forKey: realUid)
                    DispatchQueue.main.async {
                        self.buttonCommentLikeCount.setTitle(String(likeCount), for: .normal) // 좋아요 카운트 버튼 타이틀 업데이트
                    }
                } else {
                    // 좋아요 추가
                    likeCount += 1
                    likes[realUid] = true
                    DispatchQueue.main.async {
                        self.buttonCommentLikeCount.setTitle(String(likeCount) + " *", for: .normal) // 좋아요 카운트 버튼 타이틀 업데이트
                    }
                }
                post[Constants.firebaseQuoteCommentsLikesData] = likes as AnyObject?
                post[Constants.firebaseQuoteCommentsLikesCount] = likeCount as AnyObject?
                
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print("///// error 4632: \n", error.localizedDescription)
            }
        }
    }
    
    
    // MARK: 댓글 옵션 버튼 액션
    @IBAction func buttonCommentOption(_ sender: UIButton) {
        print("///// buttonCommentOption- 4783\n")
    }
}

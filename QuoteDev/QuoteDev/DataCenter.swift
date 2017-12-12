//
//  DataCenter.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import Foundation

struct QuoteComment {
    let commentKeyID: String
    let commentText: String
    let commentCreatedDate: String
    let userNickname: String
    let userUid: String
    
    init(dicData: [String:Any]) {
        self.commentKeyID = dicData[Constants.firebaseQuoteCommentsCommentKeyID] as! String
        self.commentText = dicData[Constants.firebaseQuoteCommentsCommentText] as! String
        self.commentCreatedDate = dicData[Constants.firebaseQuoteCommentsCommentCreatedDate] as! String
        self.userNickname = dicData[Constants.firebaseQuoteCommentsUserNickname] as! String
        self.userUid = dicData[Constants.firebaseQuoteCommentsUserUid] as! String
    }
}

// 추후 사용할 DataCenter 입니다.
class DataCenter {
    
    static let sharedInstance = DataCenter()
    
}

//
//  BoardDevDataCenter.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 9. 26..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import Foundation
import Firebase

class BoardDevDataCenter {
    
    // 싱글톤 패턴
    let shared: BoardDevDataCenter = BoardDevDataCenter()

    private init() {}
    
    
}

struct Board {
    let boardAutoIdKey: String
    let board_uid: String
    let board_text: String
    let board_img_url: String?
    let board_date: String
    let user_uid: String
    let user_nickname: String
    let board_no: Int
    
    init(inDictionary dictData: [String:Any], boardKey: String) {
        self.boardAutoIdKey = boardKey
        self.board_uid = dictData["board_uid"] as? String ?? "no-boarddata"
        self.board_text = dictData["board_text"] as? String ?? "no-text"
        self.board_img_url = dictData["board_img_url"] as? String
        self.board_date = dictData["board_date"] as? String ?? "no-date"
        self.user_uid = dictData["user_uid"] as? String ?? "no-data"
        self.user_nickname = dictData["user_nickname"] as? String ?? "no-nickname"
        self.board_no = dictData["board_no"] as? Int ?? 0
    }
}
struct BoardLists {
    
    
}
struct Comment {
    
    let user_uid: String
    let user_nickname: String
    let comment_text: String
    let comment_date: String
    let comment_uid: String
    
    init(inDictionary dictData: [String:Any]) {
    
        self.user_uid = dictData["user_uid"] as? String ?? "no-useruid"
        self.user_nickname = dictData["user_nickname"] as? String ?? "no-nickname"
        self.comment_text = dictData["comment_text"] as? String ?? "no-text"
        self.comment_date = dictData["comment_date"] as? String ?? "no-date"
        self.comment_uid = dictData["comment_uid"] as? String ?? "no-commnetuid"
        
    }
}

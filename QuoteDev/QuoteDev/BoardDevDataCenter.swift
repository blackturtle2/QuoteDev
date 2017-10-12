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
    let board_uid: String
    let board_text: String
    let board_img_url: URL?
    let board_date: Date
    let user_uid: String
    let user_nickname: String
    let board_count: Int
}
struct BoardLists {
    
    
}

//
//  DataCenter.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import Foundation

// UserDefaults에 저장하는 Uid의 UserDefaults Key값입니다.
let userDefaultsUid:String = "firebaseUserUid"


// 추후 사용할 DataCenter 입니다.
class DataCenter {
    
    static let sharedInstance = DataCenter()
    
}

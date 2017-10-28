//
//  Constants.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import Foundation

struct Constants {
    static let userDefaults_Uid:String = "firebaseUserUid"       // UserDefaults에 저장하는 Uid의 UserDefaults Key값입니다.
    static let userDefaults_UserNickname:String = "userNickname" //
    
    static let quoteCommentViewController:String = "QuoteCommentViewController"
    
    // auth
    static let firebaseUsersRoot:String = "Users"
    static let firebaseUserUid:String = "userUid"
    static let firebaseUserNickname:String = "userNickname"
    
    // quote main
    static let firebaseQuoteID:String = "quotes_id"
    static let firebaseQuoteText:String = "quotes_text"
    static let firebaseQuoteAuthor:String = "quotes_author"
    
    static let firebaseQuoteLikes:String = "quotes_likes"
    static let firebaseQuoteLikesData:String = "likes_data"
    static let firebaseQuoteLikesCount:String = "likes_count"
    
    static let firebaseQuoteComments:String = "quotes_comments"
    static let firebaseQuoteCommentsCount:String = "comments_count"
    
    static let userDefaultsCurrentQuoteID:String = "userDefaultsCurrentQuoteID"
    
    // setting
    static let firebaseAppVersion:String = "app_version"
    static let firebaseAppCurrentVersion:String = "current_version"
    static let firebaseAppForcedUpdateVersion:String = "forced_update_version"
    
    static let settingAlarmTime:String = "settingAlarmTime"
    static let settingDefaultQuoteMode:String = "settingDefaultQuoteMode"
    static let settingQuoteModeSerious:String = "quotes_data_kor_serious"
    static let settingQuoteModeJoyful:String = "quotes_data_kor_joyful"
}


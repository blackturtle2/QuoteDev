//
//  Constants.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import Foundation

struct Constants {
    // storyboard
    static let quoteCommentViewController:String = "QuoteCommentViewController"
    
    // auth
    static let userDefaultsUserUid:String = "firebaseUserUid" // UserDefaults에 저장하는 Uid의 Key값입니다.
    static let userDefaultsUserNickname:String = "userNickname" // UserDefaults에 저장하는 Nickname의 Key값입니다.
    
    static let firebaseUsersRoot:String = "users"
    static let firebaseUserUid:String = "user_uid"
    static let firebaseUserNickname:String = "user_nickname"
    
    // quote main
    static let firebaseQuoteID:String = "quotes_id"
    static let firebaseQuoteText:String = "quotes_text"
    static let firebaseQuoteAuthor:String = "quotes_author"
    
    static let firebaseQuoteLikes:String = "quotes_likes"
    static let firebaseQuoteLikesData:String = "likes_data"
    static let firebaseQuoteLikesCount:String = "likes_count"
    
    static let firebaseQuoteComments:String = "quotes_comments"
    static let firebaseQuoteCommentsPosts:String = "posts"
    static let firebaseQuoteCommentsCount:String = "posts_count"
    
    static let userDefaultsCurrentQuoteID:String = "userDefaultsCurrentQuoteID"
    
    // quote comment
    static let firebaseQuoteCommentsUserUid:String = "user_uid"
    static let firebaseQuoteCommentsUserNickname:String = "user_nickname"
    static let firebaseQuoteCommentsCommentKeyID:String = "comment_key_id"
    static let firebaseQuoteCommentsCommentCreatedDate:String = "comment_created_date"
    static let firebaseQuoteCommentsCommentText:String = "comment_text"
    
    // setting
    static let firebaseAppVersion:String = "app_version"
    static let firebaseAppCurrentVersion:String = "current_version"
    static let firebaseAppForcedUpdateVersion:String = "forced_update_version"
    
    static let settingAlarmTime:String = "settingAlarmTime"
    static let settingDefaultQuoteMode:String = "settingDefaultQuoteMode"
    static let settingQuoteModeSerious:String = "quotes_data_kor_serious"
    static let settingQuoteModeJoyful:String = "quotes_data_kor_joyful"
}


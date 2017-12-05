//
//  TodayViewController.swift
//  QuoteDevWidget
//
//  Created by leejaesung on 2017. 11. 27..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var imageQuoteBackground: UIImageView!
    @IBOutlet weak var labelQuoteText: UILabel!
    @IBOutlet weak var labelQuoteAuthor: UILabel!
    
    var userQuoteModeSetting = Constants.settingQuoteModeSerious
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        self.loadData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: 데이터 가져오기
    func loadData() {
        // 파이어베이스 초기화
        // AppDelegate의 configure()가 이미 실행 되었다면, 위젯에서는 별도로 configure()를 실행하지 않습니다.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        print("///// firebase app: \n", FirebaseApp.app() ?? "no data")
        
        // 먼저 UserDefaults 데이터 검증 후, 위젯 UI에 표시합니다.
        if UserDefaults.standard.object(forKey: "widgetQuoteText") != nil {
            guard let realQuoteText = UserDefaults.standard.object(forKey: "widgetQuoteText") as? String else { return }
            guard let realQuoteAuthor = UserDefaults.standard.object(forKey: "widgetQuoteAuthor") as? String else { return }
            
            self.labelQuoteText.text = "“" + realQuoteText + "”"
            self.labelQuoteAuthor.text = "- " + realQuoteAuthor + " -"
            
            // 값이 없으면, 특수문자 표시하지 않기
            if realQuoteText == "" { self.labelQuoteText.text = realQuoteText }
            if realQuoteAuthor == "" { self.labelQuoteAuthor.text = realQuoteAuthor }
            
        }
        
        // 호스트 앱의 설정에서 사용자가 설정한 기본 명언 모드 불러오기.
        if let realUserQuoteModeSetting = UserDefaults.init(suiteName: Constants.settingQuoteTodayExtensionAppGroup)?.value(forKey: Constants.settingDefaultQuoteMode) as? String {
            self.userQuoteModeSetting = realUserQuoteModeSetting
        }
        
        // 오늘 날짜를 String으로 변환
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd" // Firebase의 DB에 오늘 날짜(MMdd)에 맞춰서 오늘자 명언의 Key 값들이 저장되어 있습니다.
        let strToday = formatter.string(from: Date())
        
        // 위젯 앱의 설정과 호스트 앱의 설정이 다를 경우 OR 날짜가 바뀌었을 경우, 통신 시도하기.
        if UserDefaults.standard.string(forKey: "todayExtenstionSettingDefaultQuoteMode") != self.userQuoteModeSetting || UserDefaults.standard.string(forKey: "todayExtenstionSettingDefaultTodayDate") != strToday {
            
            // 오늘자 명언 키 값 가져오고, 명언 데이터 가져와서 UI에 표시하기
            self.getTodaysQuoteKeyAndShowData(selectedQuoteMode: self.userQuoteModeSetting, todayDate: strToday)
            
            UserDefaults.standard.set(self.userQuoteModeSetting, forKey: "settingDefaultQuoteModeOfWidget") // 기본 명언 모드 저장
            UserDefaults.standard.set(strToday, forKey: "todayExtenstionSettingDefaultTodayDate") // 오늘 날짜 저장
        }
        
        
        // 배경 이미지 표시하기
        self.imageQuoteBackground.image = UIImage(named: "temp_quote_background_image")
    }
    
    // MARK: 명언 키 값 가져오기 - 오늘 날짜에 맞는 명언 키 값 가져오고, getAndShowQuoteData() 호출하기
    func getTodaysQuoteKeyAndShowData(selectedQuoteMode:String, todayDate:String) {
        // 각 모드에 맞는 key 값 가져오기
        if selectedQuoteMode == Constants.settingQuoteModeSerious {
            // 진지 모드
            Database.database().reference().child(Constants.settingQuoteTodaySerious).child(todayDate).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                
                guard let realQouteSeriousKey = snapshot.value as? String else { return }
                print("///// data- 425: \n", realQouteSeriousKey)
                
                // 해당 키 값에 맞는 명언 데이터 가져오기
                self.getAndShowQuoteData(quoteMode: selectedQuoteMode, quoteKey: realQouteSeriousKey)
                
            }) { (error) in
                print("///// firebase error- 425: \n", error)
            }
            
        } else if selectedQuoteMode == Constants.settingQuoteModeJoyful {
            // 유쾌 모드
            Database.database().reference().child(Constants.settingQuoteTodayJoyful).child(todayDate).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                
                guard let realQouteJoyfulKey = snapshot.value as? String else { return }
                print("///// data- 5236: \n", realQouteJoyfulKey)
                
                // 해당 키 값에 맞는 명언 데이터 가져오기
                self.getAndShowQuoteData(quoteMode: selectedQuoteMode, quoteKey: realQouteJoyfulKey)
                
            }) { (error) in
                print("///// firebase error- 5236: \n", error)
            }
        }
    }
    
    
    // MARK: 명언 데이터 가져오고, UI 표시 function
    func getAndShowQuoteData(quoteMode:String, quoteKey:String) {

        // 명언 모드에 따른 데이터 통신
        Database.database().reference().child(quoteMode).child(quoteKey).observeSingleEvent(of: DataEventType.value, with: {[unowned self]  (snapshot) in
            guard let data = snapshot.value as? [String:Any] else { return }

            let quoteText = data["quotes_text"] as! String
            let quoteAuthor = data["quotes_author"] as! String
            
            // UserDefaults 저장
            UserDefaults.standard.set(quoteText, forKey: "widgetQuoteText")
            UserDefaults.standard.set(quoteAuthor, forKey: "widgetQuoteAuthor")

            // UI
            DispatchQueue.main.async {
                self.labelQuoteText.text = "“" + quoteText + "”"
                self.labelQuoteAuthor.text = "- " + quoteAuthor + " -"

                // 값이 없으면, 특수문자 표시하지 않기
                if quoteText == "" {
                    self.labelQuoteText.text = quoteText
                }

                if quoteAuthor == "" {
                    self.labelQuoteAuthor.text = quoteAuthor
                }
            }
            
        }) { (error) in
            print("///// firebase error- 2341: \n", error)
        }
    }
    
}

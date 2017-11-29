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
        if FirebaseApp.app() == nil { // AppDelegate의 configure()가 이미 실행 되었다면, 위젯에서는 별도로 configure()를 실행하지 않습니다.
            FirebaseApp.configure()
        }
        print("///// firebase app: \n", FirebaseApp.app() ?? "no data")
        
        if UserDefaults.standard.object(forKey: "widgetQuoteText") != nil {
            guard let realQuoteText = UserDefaults.standard.object(forKey: "widgetQuoteText") as? String else { return }
            guard let realQuoteAuthor = UserDefaults.standard.object(forKey: "widgetQuoteAuthor") as? String else { return }
            
            self.labelQuoteText.text = "“" + realQuoteText + "”"
            self.labelQuoteAuthor.text = "- " + realQuoteAuthor + " -"
            
            // 값이 없으면, 특수문자 표시하지 않기
            if realQuoteText == "" { self.labelQuoteText.text = realQuoteText }
            if realQuoteAuthor == "" { self.labelQuoteAuthor.text = realQuoteAuthor }
            
        }else {
            // 명언 데이터 가져오고, UI에 표시하기
            self.getAndShowQuoteData(quoteMode: "quotes_data_kor_serious", quoteKey: "52")
        }
        
        // 배경 이미지 표시하기
        self.imageQuoteBackground.image = UIImage(named: "temp_quote_background_image")
    }
    
    
    // MARK: 명언 데이터 가져오고, UI에 표시하는 function
    func getAndShowQuoteData(quoteMode:String, quoteKey:String) {

        // 명언 모드에 따른 데이터 통신
        Database.database().reference().child(quoteMode).child(quoteKey).observeSingleEvent(of: DataEventType.value, with: {[unowned self]  (snapshot) in
            guard let data = snapshot.value as? [String:Any] else { return }

//            let quoteID = data["quotes_id"] as! String
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
            

            // 전역 변수와 UserDefaults에 현재 보여지는 명언 ID를 저장합니다.
//            self.currentQuoteID = quoteID
//            UserDefaults.standard.set(quoteID, forKey: Constants.userDefaultsCurrentQuoteID)

        }) { (error) in
            print("///// firebase error- 2341: \n", error)
        }
    }
    
}

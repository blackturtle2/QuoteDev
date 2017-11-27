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
        
    @IBOutlet weak var labelQuoteText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        
        self.getAndShowQuoteData(quoteMode: "quotes_data_kor_serious", quoteKey: "52")
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
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func getAndShowQuoteData(quoteMode:String, quoteKey:String) {

        // 명언 모드에 따른 데이터 통신
        Database.database().reference().child(quoteMode).child(quoteKey).observeSingleEvent(of: DataEventType.value, with: {[unowned self]  (snapshot) in
            guard let data = snapshot.value as? [String:Any] else { return }

            let quoteID = data["quotes_id"] as! String
            let quoteText = data["quotes_text"] as! String
            let quoteAuthor = data["quotes_author"] as! String

            // UI
            DispatchQueue.main.async {
                self.labelQuoteText.text = "“" + quoteText + "”"
//                self.labelQuoteAuthor.text = "- " + quoteAuthor + " -"

                // 값이 없으면, 특수문자 표시하지 않기
                if quoteText == "" {
                    self.labelQuoteText.text = quoteText
                }

                if quoteAuthor == "" {
//                    self.labelQuoteAuthor.text = quoteAuthor
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

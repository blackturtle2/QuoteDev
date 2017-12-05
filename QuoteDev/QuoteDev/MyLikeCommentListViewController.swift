//
//  MyLikeCommentListViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 12. 2..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase

class MyLikeCommentListViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var quotesSeriousData: [[String:String]] = [[:]]
    var quotesJoyfulData: [[String:String]] = [[:]]
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        self.getUserQuotesLikesList()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    func getUserQuotesLikesList() {
        guard let realUid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(Constants.firebaseUsersRoot).child(realUid).child("user_quotes_likes")
        ref.queryOrderedByKey().observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            print("///// snapshot.value- 7293: \n", snapshot.value ?? "no data")
            
            var userQuotesLikesKeyList: [String] = []
            
            if snapshot.exists() {
                for child in snapshot.children {
                    let key = (child as AnyObject).key as String
                    userQuotesLikesKeyList.append(key)

                    print("///// key- 7923: ", userQuotesLikesKeyList)
                }
            } else {
                print("///// snapshot is not exists()- 8203 \n")
            }
            
            self.getQuotesDataOf(keyList: userQuotesLikesKeyList)
            
        }) { (error) in
            print("///// error- 7392: \n", error)
        }
    }
    
    func getQuotesDataOf(keyList: [String]) {
        for item in keyList {
            let ref = Database.database().reference().child("quotes_data_kor_serious").child(item)
            ref.observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                if snapshot.exists() {
                    guard let data = snapshot.value as? [String:Any] else { return }
                    
                    let quoteID = data[Constants.firebaseQuoteID] as! String
                    let quoteText = data[Constants.firebaseQuoteText] as! String
                    let quoteAuthor = data[Constants.firebaseQuoteAuthor] as! String
                    
                    DispatchQueue.main.async {
                        self.quotesSeriousData.append(["quoteID":quoteID, "quoteText":quoteText, "quoteAuthor":quoteAuthor])
                        self.mainTableView.reloadData()
                    }
                    
                } else {
                    print("///// serious snapshot is not exists()- 8203 \n")
                    let ref = Database.database().reference().child("quotes_data_kor_joyful").child(item)
                    ref.observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
                        if snapshot.exists() {
                            guard let data = snapshot.value as? [String:Any] else { return }
                            
                            let quoteID = data[Constants.firebaseQuoteID] as! String
                            let quoteText = data[Constants.firebaseQuoteText] as! String
                            let quoteAuthor = data[Constants.firebaseQuoteAuthor] as! String
                            
                            DispatchQueue.main.async {
                                self.quotesJoyfulData.append(["quoteID":quoteID, "quoteText":quoteText, "quoteAuthor":quoteAuthor])
                                self.mainTableView.reloadData()
                            }
                            
                        } else {
                            print("///// joyful snapshot is not exists()- 8273 \n")
                        }
                    }, withCancel: { (error) in
                        print("///// error- 9378: \n", error)
                    })
                }
                
            }, withCancel: { (error) in
                print("///// error- 8293: \n", error)
            })
        }
        
    }
    
}


/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension MyLikeCommentListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: tableView - Section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: tableView - Row 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.quotesSeriousData.count - 1
        case 1:
            return self.quotesJoyfulData.count - 1
        default:
            return 0
        }
    }
    
    // MARK: tableView - Section의 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "진지 모드"
        case 1:
            return "유쾌 모드"
        default:
            return nil
        }
    }
    
    // MARK: tableView - Cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultCell = tableView.dequeueReusableCell(withIdentifier: "MyLikeCommentListTableViewCell", for: indexPath) as! MyLikeCommentListTableViewCell
        
        switch indexPath.section {
        case 0:
            resultCell.quoteID = self.quotesSeriousData[indexPath.row + 1]["quoteID"]
            resultCell.labelQuoteText.text = self.quotesSeriousData[indexPath.row + 1]["quoteText"]
            resultCell.labelQuoteAuthor.text = self.quotesSeriousData[indexPath.row + 1]["quoteAuthor"]
            
            return resultCell
        case 1:
            resultCell.quoteID = self.quotesJoyfulData[indexPath.row + 1]["quoteID"]
            resultCell.labelQuoteText.text = self.quotesJoyfulData[indexPath.row + 1]["quoteText"]
            resultCell.labelQuoteAuthor.text = self.quotesJoyfulData[indexPath.row + 1]["quoteAuthor"]
            
            return resultCell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: tableView - Cell 선택 액션 정의
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 터치한 표시를 제거하는 액션
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

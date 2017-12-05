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
        ref.queryOrderedByKey().observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
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
            
            
            
        }) { (error) in
            print("///// error- 7392: \n", error)
        }
    }
    
}


/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension MyLikeCommentListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: tableView - Section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: tableView - Row 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: tableView - Cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultCell = tableView.dequeueReusableCell(withIdentifier: "MyLikeCommentListTableViewCell", for: indexPath) as! MyLikeCommentListTableViewCell
        
        return resultCell
    }
    
}

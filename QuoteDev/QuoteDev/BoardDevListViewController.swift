//
//  BoardDevListViewController.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 9. 26..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase
class BoardDevListViewController: UIViewController {
    // 게시글들을 가진 구조체
    var boardDatas: BoardLists?
    var reference: DatabaseReference!
    @IBOutlet weak var boardTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        boardTableView.delegate = self
        boardTableView.dataSource = self
        // Do any additional setup after loading the view.
        // UserDefault에 저장된 uid 확인
        print("UID:// ",UserDefaults.standard.string(forKey: Constants.userDefaults_Uid) ?? "no-data")
        reference = Database.database().reference()
        reference.child("board").observeSingleEvent(of: .value, with: { (dataSnap) in
            
            guard let boardsArr = dataSnap.value as? [String:Any] else{return}
            
            print("boardsArr 카운트:// ", boardsArr.count)
            for board in boardsArr {
                print("LIST BOARD:// ",board)
                print("LIST BOARD KEY:// ", board.key)
                
            }
            
            
        }) { (error) in
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnTouched(_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }

    

}
extension BoardDevListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let boardCell = tableView.dequeueReusableCell(withIdentifier: "boadrCell", for: indexPath) as! BoardDevListTableViewCell
        
        return boardCell
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

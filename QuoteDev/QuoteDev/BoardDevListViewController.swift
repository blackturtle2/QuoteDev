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
    var boardArrs: [Board] = []
    var likeCount: [String] = []
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
//        reference.child("board").observeSingleEvent(of: .value, with: { (dataSnap) in
//
//            guard let boardsArr = dataSnap.value as? [String:Any] else{return}
//
//            print("boardsArr 카운트:// ", boardsArr.count)
//
//
//            var boardArrDicData: [Board] = []
//            for board in boardsArr {
//                print("LIST BOARD:// ",board)
//                print("LIST BOARD KEY:// ", board.key)
//                guard let boardData = board.value as? [String:Any]  else {return}// board 구조체 사용예정
//                let board = Board(inDictionary: boardData, boardKey: board.key)
//                print("LIST BOARD detail board:// ",board)
//                boardArrDicData.append(board)
//                // autoid 자체가 시간순으로 들어오다보니 데이터 를 가져올때 정렬할필요있다.
//            }
//            print("BOARDARRDIC:// ", boardArrDicData)
//            self.boardArrs = boardArrDicData
//            DispatchQueue.main.async {
//
//                self.boardTableView.reloadData()
//            }
//        }) { (error) in
//
//        }
        
        // My top posts by number of stars
        let myTopPostsQuery = reference.child("board").queryOrdered(byChild: "board_count")
        print("쿼리://",myTopPostsQuery)
        myTopPostsQuery.observe(.value, with: { (data) in
            print(data.value as? [String:Any])
            
        }) { (error) in
            
        }
        // singleEvent가이닌 observe를 사용하여 체크
        // autoid 자체가 시간순으로 들어오다보니 데이터 를 가져올때 정렬할필요있다.
        reference.child("board").observe(.value, with: { (dataSnap) in
            guard let boardsArr = dataSnap.value as? [String:Any] else{return}
            
            print("boardsArr 카운트:// ", boardsArr.count)
            
            
            var boardArrDicData: [Board] = []
            
            for board in boardsArr {
                print("LIST BOARD:// ",board)
                print("LIST BOARD KEY:// ", board.key)
                guard let boardData = board.value as? [String:Any]  else {return}// board 구조체 사용예정
                let boardDetail = Board(inDictionary: boardData, boardKey: board.key)
                print("LIST BOARD detail board:// ",boardDetail)
                boardArrDicData.append(boardDetail)
            
            }
            print("BOARDARRDIC:// ", boardArrDicData)
            self.boardArrs = boardArrDicData
            
            
            DispatchQueue.main.async {
            
                
                self.likeCount = []
                self.boardTableView.reloadData()
            }
        }) { (error) in
            
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.likeCount = []
        //self.boardTableView.reloadData()
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
        return boardArrs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let boardCell = tableView.dequeueReusableCell(withIdentifier: "boadrCell", for: indexPath) as! BoardDevListTableViewCell
        
            boardCell.boardCountLabel.text = self.boardArrs[indexPath.row].board_count.description
            
            boardCell.boardCotentsLabel.text = self.boardArrs[indexPath.row].board_text
            
            boardCell.boardWriterLabel.text = self.boardArrs[indexPath.row].user_nickname
        
        
        self.reference.child("board_like").child(self.boardArrs[indexPath.row].board_uid).observe(.value, with: { (dataSnap) in
            boardCell.boardLikeCountLabel.text = "\(dataSnap.childrenCount)"
            self.likeCount.append(dataSnap.childrenCount.description)

        }, withCancel: { (error) in

        })
    
        
        
        return boardCell
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "BoardDevDetailViewController") as! BoardDevDetailViewController
        nextViewController.boardData = self.boardArrs[indexPath.row]
        //print("Detail LieCount://",likeCount,"/",self.likeCount[indexPath.row])
        let selectCell = tableView.cellForRow(at: indexPath) as? BoardDevListTableViewCell
        
        nextViewController.likeCount = selectCell?.boardLikeCountLabel.text
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
}

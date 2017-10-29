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
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        boardTableView.delegate = self
        boardTableView.dataSource = self
        
        // UserDefaults에 사용자 닉네임이 없으면, 닉네임을 받습니다.
        if UserDefaults.standard.string(forKey: Constants.userDefaultsUserNickname) == nil {
            
            // UIAlertController 생성
            let alertSetUserNickname:UIAlertController = UIAlertController(title: "닉네임 설정", message: "닉네임을 설정해주세요.", preferredStyle: .alert)
            
            // testField 추가
            alertSetUserNickname.addTextField { (textField) in
                textField.placeholder = "스티브 잡스"
            }
            
            // OK 버튼 Action 추가
            alertSetUserNickname.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak alertSetUserNickname] (_) in
                
                // 텍스트필드 호출
                let textFieldNickname = alertSetUserNickname!.textFields![0] // 위에서 직접 추가한 텍스트필드이므로 옵셔널 바인딩은 스킵.
                print("///// textField: ", textFieldNickname.text ?? "(no data)")
                
                // UserDefaults 에서 uid 호출 & 사용자가 텍스트필드에 입력한 텍스트 호출
                guard let uid = UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) else { return }
                guard let userNickname = alertSetUserNickname!.textFields?[0].text else { return }
                
                let dicUserData:[String:Any] = [Constants.firebaseUserUid:uid, Constants.firebaseUserNickname:userNickname]
                
                // Firebase DB & UserDefaults에 저장
                Database.database().reference().child(Constants.firebaseUsersRoot).child(uid).setValue(dicUserData)
                UserDefaults.standard.set(userNickname, forKey: Constants.userDefaultsUserNickname)

            }))
            
            self.present(alertSetUserNickname, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
        // UserDefault에 저장된 uid 확인
        print("UID:// ",UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) ?? "no-data")
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
            guard let boardsArr = data.value as? [String:Any] else{return}
            
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
                // query 정렬후 가져와서 클라단에서 정렬 해줍니다.(쿼리 정렬자체가 생각만큼 정렬이 안되는거 같네요.)
                let sortingData = self.boardArrs.sorted(by: {$0.board_count > $1.board_count})
                
                self.boardArrs = sortingData
                self.likeCount = []
                self.boardTableView.reloadData()
            }
        }) { (error) in
            
        }
        // singleEvent가이닌 observe를 사용하여 체크
        // autoid 자체가 시간순으로 들어오다보니 데이터 를 가져올때 정렬할필요있다.
        /*
        reference.child("board").observe(.value, with: {[unowned self] (dataSnap) in
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
        */
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
    
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    @IBAction func backBtnTouched(_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }

}


/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
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

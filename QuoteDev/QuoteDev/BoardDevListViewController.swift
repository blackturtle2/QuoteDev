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
    
    var boardArrs: [Board] = []
    var reference: DatabaseReference!
    var user_uid: String = ""
    @IBOutlet weak var boardTableView: UITableView!
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        boardTableView.delegate = self
        boardTableView.dataSource = self
        reference = Database.database().reference()
        
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
                
                // Auth 에서 uid 호출 & 사용자가 텍스트필드에 입력한 텍스트 호출
                guard let uid = Auth.auth().currentUser?.uid else { return }
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
        guard let userUID =  UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) else {return}
        user_uid = userUID
        
        // 최초 게시판 글 정보 조회 메서드 호출
        boardLoadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-          IBActions                //
    /*******************************************/
    // MARK: 뒤로가기 버튼 클릭
    @IBAction func backBtnTouched(_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: 게시판 글 정보 조회 메서드
    func boardLoadData(){
        
        let myTopPostsQuery = reference.child("board").child("board_data").queryOrdered(byChild: "board_count")
        
        myTopPostsQuery.observe(.value, with: { (data) in
            
            guard let boardsArr = data.value as? [String:Any] else{return}
            
            var boardArrDicData: [Board] = []
            
            for board in boardsArr {
                guard let boardData = board.value as? [String:Any]  else {return}// board 구조체 사용예정
                let boardDetail = Board(inDictionary: boardData, boardKey: board.key)
                boardArrDicData.append(boardDetail)
                
            }
            
            self.boardArrs = boardArrDicData
            
            
            DispatchQueue.main.async {
                // query 정렬후 가져와서 클라단에서 정렬 해줍니다.(쿼리 정렬자체가 생각만큼 정렬이 안되는거 같네요.)
                let sortingData = self.boardArrs.sorted(by: {$0.board_no > $1.board_no})
                
                self.boardArrs = sortingData
                
                self.boardTableView.reloadData()
            }
        }) { (error) in
            
        }
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
        
            boardCell.boardCountLabel.text = self.boardArrs[indexPath.row].board_no.description
            
            boardCell.boardCotentsLabel.text = self.boardArrs[indexPath.row].board_text
            
            boardCell.boardWriterLabel.text = self.boardArrs[indexPath.row].user_nickname
        
            boardCell.boardCreateAtLabel.text = self.boardArrs[indexPath.row].board_date
        
        if let _ = boardArrs[indexPath.row].board_img_url {
            boardCell.imageResultLabel.text = "image is true"
            boardCell.imageResultImgView.isHidden = false
        }else{
            boardCell.imageResultLabel.text = "image is false"
            boardCell.imageResultImgView.isHidden = true
        }
        
        self.reference.child("board_like").child(self.boardArrs[indexPath.row].board_uid).observe(.value, with: { (dataSnap) in
            boardCell.boardLikeCountLabel.text = "\(dataSnap.childrenCount)"
        }, withCancel: { (error) in

        })
        
        self.reference.child("board_comment").child(self.boardArrs[indexPath.row].board_uid).observe(.value, with: { (dataSnap) in
            boardCell.boardReqCountLabel.text = "\(dataSnap.childrenCount)"
        }) { (error) in
            print(error.localizedDescription)
        }
    
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
        nextViewController.reqCount = selectCell?.boardReqCountLabel.text
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var returnAction: [UITableViewRowAction] = []
        let deleteBoardUid = self.boardArrs[indexPath.row].board_uid
        
        let delAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete") { (action, index) in
            self.boardArrs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            self.reference.child("board").child("board_data").runTransactionBlock({ (currentData) -> TransactionResult in
                if var boardDatas = currentData.value as? [String:Any] {
                    print(boardDatas)
                    print(boardDatas.count)
                    //var updateBoardDatas: [String:Any] = [:]
                    for boardDetail in boardDatas {
                        let oneBoardData = Board(inDictionary: boardDetail.value as? [String:Any] ?? [:], boardKey: boardDetail.key)
                        
                        print(oneBoardData)
                        print(boardDetail)
                        if oneBoardData.board_uid == deleteBoardUid {
                            boardDatas.removeValue(forKey: oneBoardData.boardAutoIdKey)
                        }
                    }
                    print(boardDatas)
                    print(boardDatas.count)
                    currentData.value = boardDatas
                }
                return TransactionResult.success(withValue: currentData)
            })
        }
        delAction.backgroundColor = UIColor.orange
        
        // 본인이 작성한 게시글에 대해서만 삭제가능하도록 분기처리
        if boardArrs[indexPath.row].user_uid == user_uid {
            returnAction.append(delAction)
        }else{
            returnAction = []
        }
        return returnAction
    }
    

    
}

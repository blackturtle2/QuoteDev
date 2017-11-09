//
//  BoardDevDetailViewController.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 10. 13..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase
class BoardDevDetailViewController: UIViewController {
    
    @IBOutlet weak var boardDetailTableView: UITableView!
    @IBOutlet weak var boardHeaderView: BoardDevDetailHeaderView!
    @IBOutlet weak var commetView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
    
    var boardData: Board?
    var likeCount: String?
    var reqCount: String?
    var commentData: [Comment] = []
    var reference: DatabaseReference!
    var user_uid = ""
    var user_nickname = "#null"
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("게시판 디테일 뷰디드 로드")
        boardDetailTableView.delegate = self
        boardDetailTableView.dataSource = self
        
        //commentTextField.delegate = self
        reference = Database.database().reference()
        guard let boardLikeCount = likeCount else {return}
        guard let boardReqCount = reqCount else {return}
        
        boardHeaderView.boardLikeCountLabel.text = boardLikeCount
        boardHeaderView.boardReqCountLabel.text = boardReqCount
        guard let boardDatas = boardData else { return }
        print(boardDatas.board_uid)
        
        // 댓글 데이터 조회 queryOrdered(byChild: "board_count")
//        reference.child("board_comment").child(boardDatas.board_uid).observe(.value, with: { (data) in
//            print(data.value as? [String:Any] ?? "")
//            guard let commentArrs = data.value as? [String:Any] else{return}
//
//            var commentDataArr: [Comment] = []
//
//            for comment in commentArrs {
//                print("LIST COMENT:// ",comment)
//
//                guard let boardData = comment.value as? [String:Any]  else {return}// board 구조체 사용예정
//                let commnetDetail = Comment(inDictionary: boardData)
//                print("LIST BOARD detail board:// ",commnetDetail)
//                commentDataArr.append(commnetDetail)
//
//            }
//            print("CommentDIC:// ", commentDataArr)
//            self.commentData = commentDataArr
//
//
//            DispatchQueue.main.async {
//
//                self.boardDetailTableView.reloadData()
//
//            }
//        }) { (error) in
//
//        }
        // 댓글 데이터 조회하여 정렬
        reference.child("board_comment").child(boardDatas.board_uid).queryOrdered(byChild: "comment_date").observe(.value, with: { (data) in
            print(data.value as? [String:Any] ?? "")
            guard let commentArrs = data.value as? [String:Any] else{return}
            
            var commentDataArr: [Comment] = []
            
            for comment in commentArrs {
                print("LIST COMENT:// ",comment)
                
                guard let boardData = comment.value as? [String:Any]  else {return}// board 구조체 사용예정
                let commnetDetail = Comment(inDictionary: boardData)
                print("LIST BOARD detail board:// ",commnetDetail)
                commentDataArr.append(commnetDetail)
                
            }
            print("CommentDIC:// ", commentDataArr)
            self.commentData = commentDataArr
            
            DispatchQueue.main.async {
                // query 정렬후 가져와서 클라단에서 정렬 해줍니다.(쿼리 정렬자체가 생각만큼 정렬이 안되는거 같네요.)
                let sortingData = self.commentData.sorted(by: {$0.comment_date > $1.comment_date})
                
                self.commentData = sortingData
                
                self.boardDetailTableView.reloadData()
            }
            
        }) { (error) in
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(BoardDevDetailViewController.keyboardWillShowHide(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BoardDevDetailViewController.keyboardWillShowHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        if let imgUrlStr = boardData?.board_img_url, let imgUrl = URL(string: imgUrlStr){
            print("이미지 존재")
            URLSession.shared.dataTask(with: imgUrl, completionHandler: { (data, response, error) in
                guard let imgData = data else {return}
                // 시점 고려하고 코너가 안먹넹
                DispatchQueue.main.async {
                    self.boardHeaderView.boardImgView.layer.cornerRadius = 20
                    self.boardHeaderView.boardImgView.image = UIImage(data: imgData)
                    
                }
            }).resume()
        }else{
            print("이미지 없다")
            // 디테일뷰로 넘어올때 이미지 정보가 없을경우 화면에 이미지뷰를 제거하여 priority 설정에 따라 제거후 오토레이아웃 적용
            // 헤더뷰를 다시 그린다.
            boardHeaderView.boardImgView.removeFromSuperview()
            boardHeaderView.setNeedsLayout()
            boardHeaderView.layoutIfNeeded()
            
        }
        
        guard let uid = UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) else {return}
        user_uid = uid
        guard let nickName = UserDefaults.standard.string(forKey: Constants.userDefaultsUserNickname) else {return}
        user_nickname = nickName
    }
    
    // 뷰 컨트롤러 루트 뷰의 경계가 바뀔 때마다 재정의
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("게시판 디테일 뷰 디드 LayouSubView 호출")
        // 현재 테이블 뷰의 헤더뷰 존재 여부 판단
        //guard  let headerView = boardDetailTableView.tableHeaderView as? BoardDevDetailHeaderView else { return }
        
        
//        if let imgUrlStr = boardData?.board_img_url, let imgUrl = URL(string: imgUrlStr){
//            print("이미지 존재")
//            URLSession.shared.dataTask(with: imgUrl, completionHandler: { (data, response, error) in
//                guard let imgData = data else {return}
//                // 시점 고려하고 코너가 안먹넹
//                DispatchQueue.main.async {
//                    self.boardHeaderView.boardImgView.layer.cornerRadius = 20
//                    self.boardHeaderView.boardImgView.image = UIImage(data: imgData)
//
//                }
//            }).resume()
//        }else{
//            print("이미지 없다")
//            // 디테일뷰로 넘어올때 이미지 정보가 없을경우 화면에 이미지뷰를 제거하여 priority 설정에 따라 제거후 오토레이아웃 적용
//            // 헤더뷰를 다시 그린다.
//            boardHeaderView.boardImgView.removeFromSuperview()
//            boardHeaderView.setNeedsLayout()
//            boardHeaderView.layoutIfNeeded()
//
//        }
//
        
        guard  let boardDatas = boardData else { return }
        boardHeaderView.boardCotentsLabel.text = boardDatas.board_text
        boardHeaderView.boardCountLabel.text = boardDatas.board_no.description
        boardHeaderView.boardWriterLabel.text = boardDatas.user_nickname
        boardHeaderView.boardCreateAtLabel.text = boardDatas.board_date
        
        
        
        boardHeaderView.boardUID = boardDatas.board_uid
        //boardHeaderView.userUID = boardDatas.user_uid
        
        // 헤더뷰의 최소크기 할당
        // systemLayoutSizeFitting(_ targetSize: CGSize): 뷰가 유지하는 제약을 채우는 뷰의 사이즈를 돌려줍니다.
        // UILayoutFittingCompressedSize - 가능한 가장 작은 크기를 사용하는 옵션입니다.
        let size = boardHeaderView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        // 테이블 뷰 헤더의 프레임을 변경하면 새로운 레이아웃주기가 시작
        // 레이아웃 루프가 반복되지 않도록 값이 변경됬을때만 헤더뷰를 변경된 값의 헤더뷰로 할당
        if boardHeaderView.frame.size.height != size.height{
            
            boardHeaderView.frame.size.height = size.height
            boardDetailTableView.tableHeaderView = boardHeaderView
            
            boardHeaderView.setNeedsLayout()
            boardDetailTableView.layoutIfNeeded()
            
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("뷰윌")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-         IBActions                 //
    /*******************************************/
    
    // MARK: 댓글 등록 버튼
    @IBAction func pushBtnTouched(_ sender: UIButton){
        guard let boardData = boardData, let comment = commentTextField.text else {return}
        print(boardData.board_uid)
        print(commentTextField.text ?? "no-text")
        
        let nowDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let currentDate = dateFormatter.string(from: nowDate)
        let commnet_uid = "\(user_uid)\(currentDate)"
        
        
        let autoID = reference.child("board_comment").child(boardData.board_uid).childByAutoId().key
        reference.child("board_comment").child(boardData.board_uid).runTransactionBlock({ (currentData) -> TransactionResult in
            var commentData = currentData.value as? [String:Any] ?? [:]
            var insertData: [String:Any] = [:]
            insertData.updateValue(self.user_uid, forKey: "user_uid")
            insertData.updateValue(comment, forKey: "comment_text")
            insertData.updateValue(self.user_nickname, forKey: "user_nickname") // date형식의경우 계속 시간이 변경됨
            insertData.updateValue(self.user_uid, forKey: "user_uid")
            insertData.updateValue(currentDate, forKey: "comment_date")
            insertData.updateValue(commnet_uid, forKey: "comment_uid") // board_count(고유 글번호)
            
            commentData.updateValue(insertData, forKey: autoID)
            currentData.value = commentData
            
            NotificationCenter.default.post(name: .UIKeyboardWillHide, object: nil)
            
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, commit, dataSnap) in
            guard let reqCount = dataSnap?.childrenCount else {return}
            
            DispatchQueue.main.async {
                self.boardDetailTableView.reloadData()
                self.boardHeaderView.boardReqCountLabel.text = "\(reqCount)"
            }
        }
    }
    
    // MARK: 테이블뷰 탭 제스쳐
    @IBAction func tableViewTapGesture(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: .UIKeyboardWillHide, object: nil)
    }
    
   
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    // MARK: 키보드 올리기 or 내리기
    func keyboardWillShowHide(notification: Notification) {
        print("///// keyboardWillShowOrHide")
        
        // guard-let으로 nil 값이면, 키보드를 내립니다.
        guard let userInfo = notification.userInfo else {
            
            DispatchQueue.main.async {
                self.commentTextField.resignFirstResponder() // 키보드 내리기.
                self.commentTextField.text = ""
                self.commentViewBottomConstraint.constant = 0 // 댓글 작성칸 내리기.
                self.view.layoutIfNeeded() // UIView layout 새로고침.
            }

            return
        }
        
        // notification.userInfo를 이용해 키보드와 UIView를 함께 올립니다.
        print("///// userInfo: ", userInfo)
        
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = UIViewAnimationOptions(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16)
        let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: [.beginFromCurrentState, animationCurve],
            animations: {
                guard let window = self.view.window else {return}
                self.commentViewBottomConstraint.constant = (self.view.bounds.maxY - window.convert(frameEnd, to: self.view).minY)
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
    }

}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/

extension BoardDevDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardDevDetailCommentCell", for: indexPath) as! BoardDevDetailCommentCell
        
        cell.userNickNameLabel.text = commentData[indexPath.row].user_nickname
        cell.commentTextLabel.text = commentData[indexPath.row].comment_text
        cell.commentCreateAtLabel.text = commentData[indexPath.row].comment_date
        cell.commentUID = commentData[indexPath.row].comment_uid
        
        self.reference.child("board_comment_like").child(self.commentData[indexPath.row].comment_uid).observe(.value, with: { (dataSnap) in
            cell.commentLikeLabel.text = "\(dataSnap.childrenCount)"
            
            
        }, withCancel: { (error) in
            
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

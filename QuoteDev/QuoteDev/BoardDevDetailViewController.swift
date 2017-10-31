//
//  BoardDevDetailViewController.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 10. 13..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class BoardDevDetailViewController: UIViewController {
    
    @IBOutlet weak var boardDetailTableView: UITableView!
    @IBOutlet weak var boardHeaderView: BoardDevDetailHeaderView!
    @IBOutlet weak var commetView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
    
    var boardData: Board?
    var likeCount: String?
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("게시판 디테일 뷰디드 로드")
        boardDetailTableView.delegate = self
        boardDetailTableView.dataSource = self
        //commentTextField.delegate = self
        
        guard  let boardLikeCount = likeCount else {return}
        boardHeaderView.boardLikeCountLabel.text = "\(boardLikeCount)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(BoardDevDetailViewController.keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
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
    //MARK:-         Functions                 //
    /*******************************************/
    
    // MARK: 키보드 올리기 or 내리기
    func keyboardWillShow(notification: Notification) {
        print("///// keyboardWillShowOrHide")
        
        // guard-let으로 nil 값이면, 키보드를 내립니다.
        guard let userInfo = notification.userInfo else {
            self.commentTextField.resignFirstResponder() // 키보드 내리기.

            self.commentViewBottomConstraint.constant = 0 // 댓글 작성칸 내리기.
            self.view.layoutIfNeeded() // UIView layout 새로고침.
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
                self.commentViewBottomConstraint.constant = (self.view.bounds.maxY - self.view.window!.convert(frameEnd, to: self.view).minY)
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
    }

}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension BoardDevDetailViewController: UITextFieldDelegate {
    
}

extension BoardDevDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerCell = tableView.dequeueReusableCell(withIdentifier: "BoardDevDetailHeaderCell") as! BoardDevDetailHeaderCell
//
//        return headerCell
//    }
//    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoardDevDetailCommentCell", for: indexPath) as! BoardDevDetailCommentCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

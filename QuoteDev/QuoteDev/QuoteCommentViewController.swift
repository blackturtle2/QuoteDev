//
//  QuoteCommentViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class QuoteCommentViewController: UIViewController {

    @IBOutlet weak var tableViewMain: UITableView! // 메인 테이블 뷰
    
    @IBOutlet weak var viewWritingCommentBox: UIView! // 댓글 작성 박스 뷰
    @IBOutlet weak var textFieldWritingComment: UITextField! // 댓글 작성 텍스트필드
    
    @IBOutlet weak var constraintOfViewWritingCommentBox: NSLayoutConstraint! // 댓글 작성 박스 Bottom의 constraint
    
    @IBOutlet var tapGestureTableViewMain: UITapGestureRecognizer! // 키보드 올리기 or 내리기 목적의 탭제스쳐
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
        self.tapGestureTableViewMain.isEnabled = false // 댓글 작성 텍스트필드에 커서가 올라가서 키보드가 올라왔을 때에만 탭제스쳐가 작동하도록 설계합니다.
        
        // 댓글 작성 텍스트필드 터치 시, 키보드 올리기 위한 키보드 노티 옵저버 등록.
        NotificationCenter.default.addObserver( // 키보드 올리기
            self,
            selector: #selector(QuoteCommentViewController.keyboardWillShowOrHide(notification:)),
            name: .UIKeyboardWillShow,
            object: nil)
        
        NotificationCenter.default.addObserver( // 키보드 내리기
            self,
            selector: #selector(QuoteCommentViewController.keyboardWillShowOrHide(notification:)),
            name: .UIKeyboardWillHide,
            object: nil)
        
        // UI 적용
        self.textFieldWritingComment.layer.borderColor = UIColor.black.cgColor
        self.textFieldWritingComment.layer.borderWidth = 1.0
        self.textFieldWritingComment.layer.cornerRadius = 5; // borderStyle.roundedRect가 작동하지 않는 관계로.. cornerRadius를 강제로 삽입합니다.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    // MARK: 탭제스쳐로 키보드 내리기
    @IBAction func tabGestureTableViewMain(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: 댓글 작성 완료 버튼(Push) 액션 정의
    @IBAction func buttonCommentPushAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: 키보드 올리기 or 내리기 Function 정의
    func keyboardWillShowOrHide(notification: Notification) {
        print("///// keyboardWillShowOrHide")
        
        // guard-let으로 nil 값이면, 키보드를 내립니다.
        guard let userInfo = notification.userInfo else {
            self.textFieldWritingComment.resignFirstResponder() // 키보드 내리기.
            self.constraintOfViewWritingCommentBox.constant = 0 // 댓글 작성칸 내리기.
            self.view.layoutIfNeeded() // UIView layout 새로고침.
            return
        }
        
        // notification.userInfo를 이용해 키보드가 올라올 때, self.view를 같이 올립니다.
        print("///// userInfo: ", userInfo)
        
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = UIViewAnimationOptions(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16)
        let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: [.beginFromCurrentState, animationCurve],
            animations: {
                // 기존 코드: 댓글 작성 박스의 constant만 올렸습니다.
                // self.constraintOfViewWritingCommentBox.constant = (self.view.bounds.maxY - self.view.window!.convert(frameEnd, to: self.view).minY)
                
                // 아래 수정 코드: 키보드가 올라오면서 작아진 화면에서 댓글 목록이 자연스럽게 스크롤되도록 self.view의 height를 조정합니다.
                self.view.frame.size.height -= (self.view.bounds.maxY - self.view.window!.convert(frameEnd, to: self.view).minY)
                // self.tableViewMain.setContentOffset(CGPoint(x: 0, y: self.view.window!.convert(frameEnd, to: self.view).minY), animated: true) // 테이블 뷰 자동 스크롤
                self.view.layoutIfNeeded()
                
                self.tapGestureTableViewMain.isEnabled = true // 키보드가 올라왔을 때에만 탭제스쳐를 작동시킵니다.
        },
            completion: nil
        )
    }
    
}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
// MARK: extension - UITableViewDelegate, UITableViewDataSource
extension QuoteCommentViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: tableView - row의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // MARK: tableView - row의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: tableView - cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath)
        
        return cell
    }
    
}

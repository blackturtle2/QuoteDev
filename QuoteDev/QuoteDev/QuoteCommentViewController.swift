//
//  QuoteCommentViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class QuoteCommentViewController: UIViewController {

    @IBOutlet weak var tableViewMain: UITableView!
    
    @IBOutlet weak var viewWritingCommentBox: UIView!
    @IBOutlet weak var textFieldWritingComment: UITextField!
    
    @IBOutlet weak var constraintOfViewWritingCommentBox: NSLayoutConstraint!
    @IBOutlet weak var constraintOfTableViewMain: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
        self.textFieldWritingComment.delegate = self
        
        // 댓글 작성 텍스트필드 터치 시, 키보드 올리기 위한 키보드 노티 옵저버 등록.
        // 키보드 올리기
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(QuoteCommentViewController.keyboardWillShowOrHide(notification:)),
            name: .UIKeyboardWillShow,
            object: nil)
        
        // 키보드 내리기
        NotificationCenter.default.addObserver(
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

}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension QuoteCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension QuoteCommentViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    // 키보드 올리기 or 내리기
    func keyboardWillShowOrHide(notification: Notification) {
        print("///// keyboardWillShowOrHide")
        
        // guard-let으로 nil 값이면, 키보드를 내립니다.
        guard let userInfo = notification.userInfo else {
            self.textFieldWritingComment.resignFirstResponder() // 키보드 내리기.
            self.constraintOfViewWritingCommentBox.constant = 0 // 댓글 작성칸 내리기.
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
                self.constraintOfViewWritingCommentBox.constant = (self.view.bounds.maxY - self.view.window!.convert(frameEnd, to: self.view).minY)
                self.constraintOfTableViewMain.constant = (self.view.bounds.maxY - self.view.window!.convert(frameEnd, to: self.view).minY)
                self.tableViewMain.layoutIfNeeded()
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
    }
}

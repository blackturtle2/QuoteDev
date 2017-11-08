//
//  QuoteCommentViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase
import Toaster

class QuoteCommentViewController: UIViewController {
    
    var QuoteText:String = ""
    var QuoteAuthor:String = ""
    
    @IBOutlet weak var labelHeaderQuoteText: UILabel! // 명언 텍스트 레이블
    @IBOutlet weak var labelHeaderQuoteAuthor: UILabel! // 명언 저자 레이블
    @IBOutlet weak var viewMoreCommentsHorizontalLine: UIView! // 댓글 더보기 버튼 위 가로줄
    @IBOutlet weak var buttonMoreComments: UIButton! // 댓글 더보기 버튼
    @IBOutlet weak var constraintButtonMoreCommentsHeight: NSLayoutConstraint! // 댓글 더보기 버튼 높이 Constraints
    
    @IBOutlet weak var tableViewMain: UITableView! // 메인 테이블 뷰
    
    @IBOutlet weak var viewWritingCommentBox: UIView! // 댓글 작성 박스 뷰
    @IBOutlet weak var textFieldWritingComment: UITextField! // 댓글 작성 텍스트필드
    
    @IBOutlet weak var constraintOfViewWritingCommentBox: NSLayoutConstraint! // 댓글 작성 박스 Bottom의 constraint
    
    @IBOutlet var tapGestureTableViewMain: UITapGestureRecognizer! // 키보드 올리기 or 내리기 목적의 탭제스쳐
    
    var todayQuoteID: String?
    var userNickname: String?
    
    var commentsList: [QuoteComment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 댓글 더 보기 버튼 숨기기
        self.buttonMoreComments.isHidden = true
        self.viewMoreCommentsHorizontalLine.isHidden = true
        self.constraintButtonMoreCommentsHeight.constant = 0
        
        // 테이블헤더 뷰 UI 세팅
        self.labelHeaderQuoteText.text = self.QuoteText
        self.labelHeaderQuoteAuthor.text = self.QuoteAuthor
        self.tableViewMain.tableHeaderView?.layoutIfNeeded()

        if let headerView = self.tableViewMain.tableHeaderView {
            // 테이블헤더 뷰에 데이터를 입력한 후, 헤더뷰의 높이를 재조정합니다.
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                self.tableViewMain.tableHeaderView = headerView
            }
        }

        // Delegate & DataSource
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
        
        // 타이틀에 오늘 날짜 나오도록 세팅
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        self.navigationItem.title = formatter.string(from: Date())
        
        // 전역 변수의 QuoteID에 현재 CurrentQuoteID 저장
        self.todayQuoteID = UserDefaults.standard.string(forKey: Constants.userDefaultsCurrentQuoteID)
        self.userNickname = UserDefaults.standard.string(forKey: Constants.userDefaultsUserNickname)
        
        // Firebase에 댓글 노드가 없는 케이스 예외처리 - 댓글 노드를 만듭니다.
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if snapshot.exists() {
                self.findCommentDataToLastOf(itemsCount: 10, moveToLast: false)
            }else {
                // snapshot이 없을 경우, use 데이터 생성.
                // use는 DB 사용 여부 체크 목적 무의미한 데이터 / posts_count는 댓글 총 개수 카운트
                let dicInitialData:[String:Any] = ["use":true, "posts_count":0]
                Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID).setValue(dicInitialData) // realTodayQuoteID의 노드 생성.
            }
            
        }) { (error) in
            print("///// error- 3130: \n", error.localizedDescription)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    
    // MARK: 댓글 데이터 불러오기
    func findCommentDataToLastOf(itemsCount: UInt, moveToLast: Bool) {
       guard let realTodayQuoteID = self.todayQuoteID else { return }
        Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID).child(Constants.firebaseQuoteCommentsPosts).queryLimited(toLast: itemsCount).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            print("///// snapshot- 9843: \n", snapshot.value ?? "(no data)")
            
            // snapshot.value는 시간순으로 데이터가 오는데, guard-let을 통과하면서 정렬이 깨집니다.
            // 따라서 sorted()를 이용해, 시간순으로 정렬합니다. - Firebase의 AutoID key 값은 자동으로 시간순 정렬입니다.
            guard let realCommentsList = snapshot.value as? [String:Any] else { return }
            let sortedRealCommentsList = realCommentsList.sorted(by: {$0.key < $1.key} )
            
            // 전역 변수에 댓글 데이터를 저장합니다.
            for item in sortedRealCommentsList {
                let oneCommentData = QuoteComment(dicData: item.value as! [String : Any])
                self.commentsList.append(oneCommentData)
                print("///// item(QuoteComment)- 9843: \n", oneCommentData)
            }
            print("///// self.commentsList- 9843: \n", self.commentsList)
            
            // 테이블 뷰 전체 리로드
            DispatchQueue.main.async {
                self.tableViewMain.reloadData()
                
                // 댓글을 작성하면, 테이블 뷰 맨 아래로 이동합니다.
                if moveToLast {
                    let lastIndexPath = IndexPath(row: self.commentsList.count-1, section: 0)
                    self.tableViewMain.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
                }
            }
            
        }) { (error) in
            print("///// error- 9843: \n", error)
        }
    }
    
    // MARK: 댓글 더보기 버튼 액션 정의
    @IBAction func buttonHeaderMoreCommentsAction(_ sender: UIButton) {
        print("///// buttonHeaderMoreCommentsAction- 9723")
    }
    
    // MARK: 댓글 작성 완료 버튼(Push) 액션 정의
    @IBAction func buttonCommentPushAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: .UIKeyboardWillHide, object: nil)
        
        // 댓글 텍스트필드가 비어 있을 때의 예외처리
        if self.textFieldWritingComment.text?.isEmpty == true {
            print("///// textFieldWritingComment.text == nil- 4123: \n")
            let alert = UIAlertController(title: nil, message: "댓글을 작성해주세요.", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        Toast.init(text: "댓글을 Push 합니다.").show()
        
        self.postCommentData()
    }
    
    // MARK: 댓글 Post Function 정의
    func postCommentData() {
        guard let realUid = Auth.auth().currentUser?.uid else { return }
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        guard let realUserNickname = self.userNickname else { return }
        
        // 댓글 카운트 데이터, 1 올리기
        Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID).child("posts_count").runTransactionBlock({ (currentData) -> TransactionResult in
            guard var postCountData = currentData.value as? Int else { return TransactionResult.success(withValue: currentData) }
            postCountData += 1
            currentData.value = postCountData
            
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print("///// error 4632: \n", error.localizedDescription)
            }
        }
        
        // 실제 Post 통신 부분
        let ref = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID)
        let key = ref.childByAutoId().key
        let post = [Constants.firebaseQuoteCommentsUserUid: realUid,
                    Constants.firebaseQuoteCommentsUserNickname: realUserNickname,
                    Constants.firebaseQuoteCommentsCommentKeyID: key,
                    Constants.firebaseQuoteCommentsCommentCreatedDate: getDateStringOf(date: Date()),
                    Constants.firebaseQuoteCommentsCommentText: self.textFieldWritingComment.text ?? ""]
        let childUpdates = ["/\(Constants.firebaseQuoteCommentsPosts)/\(key)": post]
        ref.updateChildValues(childUpdates)
        
        // UI 새로고침
        self.textFieldWritingComment.text = ""
        self.findCommentDataToLastOf(itemsCount: 1, moveToLast: true)
    }
    
    // MARK: Date 데이터를 입력하면, DateFormatter()를 거쳐서 String으로 반환하는 function
    func getDateStringOf(date: Date ,format: String = "yyyy-MM-dd E HH:mm:ss") -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = format
        return formmater.string(from: date as Date)
    }
    
    // MARK: 탭제스쳐로 키보드 내리기
    @IBAction func tabGestureTableViewMain(_ sender: UITapGestureRecognizer) {
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
            self.tapGestureTableViewMain.isEnabled = false // 키보드가 올라왔을 때에만 탭제스쳐를 작동시킵니다.
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
        return self.commentsList.count
    }
    
    // MARK: tableView - row의 높이
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: tableView - cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath) as! QuoteCommentTableViewCell
        let commentData = self.commentsList[indexPath.row]
        print("///// commentData- 4123:", commentData)
        
        let str = commentData.commentKeyID
        cell.labelCommentKeyID.text = "# commit: " + str[str.index(after: String.Index.init(encodedOffset: 9))..<str.endIndex] // String 자르기
        cell.labelCommentWriter.text = "by " + commentData.userNickname
        cell.labelCommentText.text = commentData.commentText
        cell.labelCommentCreatedDate.text = "// " + commentData.commentCreatedDate
        cell.buttonCommentLikeCount.setTitle("0", for: .normal)
        
        cell.commentKeyID = commentData.commentKeyID
        
        return cell
    }
    
}

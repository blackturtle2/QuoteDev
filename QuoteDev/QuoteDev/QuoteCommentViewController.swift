//
//  QuoteCommentViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 20..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import MessageUI
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
    
    @IBOutlet weak var mainTableView: UITableView! // 메인 테이블 뷰
    
    @IBOutlet weak var viewWritingCommentBox: UIView! // 댓글 작성 박스 뷰
    @IBOutlet weak var textFieldWritingComment: UITextField! // 댓글 작성 텍스트필드
    
    @IBOutlet weak var constraintOfViewWritingCommentBox: NSLayoutConstraint! // 댓글 작성 박스 Bottom의 constraint
    
    @IBOutlet var tapGestureTableViewMain: UITapGestureRecognizer! // 키보드 올리기 or 내리기 목적의 탭제스쳐
    
    var todayQuoteID: String?
    var userNickname: String?
    
    var commentsList: [QuoteComment] = [] // 댓글 데이터
    var commentsLikeData: [String:Int] = [:] // 댓글 좋아요 데이터  ( ex. CommentKeyID : 1 ) // findShowCommentsLike() 참고
    var commentsMyLikeOrNot: [String:Bool] = [:] // 현재 사용자 누른 댓글 좋아요 여부 확인 데이터 ( ex. CommentKeyID : true ) // findShowCommentsLike() 참고
    
    var currentLastCommentCount = 0
    
    var keyboardHeight:CGFloat = 250 // Toast 높이 조절을 변수 ( 키보드 notification을 받아서 수정합니다. )
    
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블헤더 뷰 UI 세팅
        self.labelHeaderQuoteText.text = self.QuoteText
        self.labelHeaderQuoteAuthor.text = self.QuoteAuthor
        self.mainTableView.tableHeaderView?.layoutIfNeeded()

        if let headerView = self.mainTableView.tableHeaderView {
            // 테이블헤더 뷰에 데이터를 입력한 후, 헤더뷰의 높이를 재조정합니다.
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                self.mainTableView.tableHeaderView = headerView
            }
        }

        // Delegate & DataSource
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        self.tapGestureTableViewMain.isEnabled = false // 댓글 작성 텍스트필드에 커서가 올라가서 키보드가 올라왔을 때에만 탭제스쳐가 작동하도록 설계합니다.
        
        // 댓글 작성 텍스트필드 터치 시, 키보드 올리기 위한 키보드 노티 옵저버 등록.
        self.addNotificationObserver()
        
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
        
        // 사용자에게 닉네임 설정 물어보기
        self.postUserNickName()
        
        // 댓글 더 보기 버튼 숨기기
        self.getCommentsCountAndShowEnableMoreCommentsButton()
        
        // Firebase에 댓글 노드가 없는 케이스 예외처리 - 댓글 노드를 만듭니다.
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if snapshot.exists() {
                self.findCommentDataToLastOf(isAllLoad: false, lastCount: 10, moveToLast: false)
                self.findShowCommentsLike()
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
    // MARK: 댓글 개수 가져오고, 댓글 더 보기 버튼 활성화 여부 결정
    func getCommentsCountAndShowEnableMoreCommentsButton() {
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        let countRef = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID)
        countRef.child(Constants.firebaseQuoteCommentsCount).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            // 네트워크 인디케이터
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            print("///// snapshot.exists()- 3924: ", snapshot)
            
            guard let data = snapshot.value as? Int else { return }
            if data > 10 { // 댓글이 10개 이상이면, 더 보기 버튼 활성화
                DispatchQueue.main.async {
                    self.buttonMoreComments.isEnabled = true
                    self.buttonMoreComments.setTitle("댓글 더 보기" + " (" + String(data - 10) + ")", for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.buttonMoreComments.isEnabled = false
                }
            }
            
        }) { (error) in
            print("///// error- 6234: \n", error.localizedDescription)
        }
    }
    
    // MARK: 닉네임 세팅
    func postUserNickName() {
        // UserDefaults에 사용자 닉네임이 없으면, 닉네임을 받습니다.
        if UserDefaults.standard.string(forKey: Constants.userDefaultsUserNickname) == nil {
            // 네트워크 인디케이터
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            // 이미 사용중인 닉네임 리스트 저장 변수
            var savedNicknameList:[String] = []
            
            // 이미 사용중인 닉네임 리스트 가져오기
            let getSavedNicknameListRef = Database.database().reference().child("users_nicknames")
            getSavedNicknameListRef.observe(DataEventType.value, with: { (snapshot) in
                // 네트워크 인디케이터
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                guard let data = snapshot.value as? [String:String] else { return }
                savedNicknameList = []
                for item in data {
                    savedNicknameList.append(item.value)
                    print("///// item.value- 6948:", item.value)
                }
            }, withCancel: { (error) in
                print("///// error- 6948:", error)
            })
            
            // UIAlertController 생성
            let alertSetUserNickname:UIAlertController = UIAlertController(title: "닉네임 설정", message: "닉네임을 설정해주세요.", preferredStyle: .alert)
            
            // testField 추가
            alertSetUserNickname.addTextField { (textField) in
                textField.placeholder = "스티브잡스"
                textField.tag = 0
                textField.delegate = self as UITextFieldDelegate
            }
            
            // OK 버튼 Action 추가
            alertSetUserNickname.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { [weak alertSetUserNickname] (_) in
                
                // 텍스트 필드 호출
                let textFieldNickname = alertSetUserNickname!.textFields![0] // 바로 위에서 직접 추가한 텍스트필드이므로 옵셔널 바인딩은 스킵.
                print("///// textField: ", textFieldNickname.text ?? "(no data)")
                
                // 예외처리: 텍스트 필드가 비어 있는 케이스
                guard let realUserNickname = textFieldNickname.text else { return }
                if textFieldNickname.text == "" {
                    let customToast = Toast.init(text: "닉네임을 입력해주세요.")
                    customToast.view.bottomOffsetPortrait = self.keyboardHeight // 키보드가 올라온 상태에서 토스트를 표시할 때의 높이 커스텀
                    customToast.show()
                    
                    // 닉네임 리스트 옵저버 해제
                    getSavedNicknameListRef.removeAllObservers()
                    self.present(alertSetUserNickname!, animated: true, completion: nil)
                    return
                }
                
                // 예외처리: 닉네임 허용 불가 케이스
                let doNotAllowNicknameList = ["이재성", "leejaesung", "까만거북이", "까북", "blackturtle2", "kabook", "개발자명언", "quotedev", "관리자", "운영자", "admin", "administrator", "supervisor", "manager", "아이폰", "아이패드", "iOS", "iPhone", "iPad", "애플", "Apple"]
                for item in doNotAllowNicknameList {
                    if realUserNickname.containsIgnoringCase(find: item) {
                        let customToast = Toast.init(text: "'\(item)': 포함된 해당 닉네임을 사용할 수 없습니다.")
                        customToast.view.bottomOffsetPortrait = self.keyboardHeight // 키보드가 올라온 상태에서 토스트를 표시할 때의 높이 커스텀
                        customToast.show()
                        
                        // 닉네임 리스트 옵저버 해제
                        getSavedNicknameListRef.removeAllObservers()
                        self.present(alertSetUserNickname!, animated: true, completion: nil)
                        return
                    }
                }
                
                // 예외처리: 사용중인 닉네임 허용 불가 케이스
                for item in savedNicknameList {
                    if realUserNickname == item {
                        let customToast = Toast.init(text: "이미 사용중인 닉네임입니다.")
                        customToast.view.bottomOffsetPortrait = self.keyboardHeight // 키보드가 올라온 상태에서 토스트를 표시할 때의 높이 커스텀
                        customToast.show()
                        
                        // 닉네임 리스트 옵저버 해제
                        getSavedNicknameListRef.removeAllObservers()
                        self.present(alertSetUserNickname!, animated: true, completion: nil)
                        return
                    }
                }
                
                // Firebase DB & UserDefaults에 저장
                guard let realUid = Auth.auth().currentUser?.uid else { return }
                
                // 사용자 정보에 닉네임 저장
                let userNicknameRef = Database.database().reference().child(Constants.firebaseUsersRoot).child(realUid).child("user_nickname")
                userNicknameRef.setValue(realUserNickname)
                
                // 닉네임 리스트에 닉네임 저장
                let nicknameListRef = Database.database().reference().child("users_nicknames").child(realUid)
                nicknameListRef.setValue(realUserNickname)
                
                // 닉네임 리스트 옵저버 해제
                getSavedNicknameListRef.removeAllObservers()
                
                UserDefaults.standard.set(realUserNickname, forKey: Constants.userDefaultsUserNickname)
                self.userNickname = realUserNickname // 전역 변수 저장
                
                Toast.init(text: "닉네임이 저장되었습니다.").show()
            }))
            
            // Cancel 버튼 Action 추가
            alertSetUserNickname.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                // 닉네임 리스트 옵저버 해제
                getSavedNicknameListRef.removeAllObservers()
                
                // 이전 뷰로 이동
                self.navigationController?.popViewController(animated: true)
            }))
            
            // UIAlertController 띄우기
            self.present(alertSetUserNickname, animated: true, completion: nil)
        }
    }
    
    
    // MARK: 댓글 작성 텍스트필드 터치 시, 키보드 올리기 위한 키보드 노티 옵저버 등록
    func addNotificationObserver() {
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
    }
    
    // MARK: 댓글 데이터 불러오기
    func findCommentDataToLastOf(isAllLoad: Bool, lastCount: Int, moveToLast: Bool) {
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        let ref = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID).child(Constants.firebaseQuoteCommentsPosts)
        var query: DatabaseQuery?
        
        if lastCount > 100 || isAllLoad == true { // Firebase에서 100개 이상은 지원하지 않으므로, 댓글 전체를 불러옵니다.
            query = ref.queryOrderedByValue()
        }else {
            query = ref.queryLimited(toLast: UInt(lastCount))
        }
        
        guard let realQuery = query else { return }
        realQuery.observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            // 네트워크 인디케이터
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            print("///// snapshot- 9843: \n", snapshot.value ?? "(no data)")
            
            // snapshot.value는 시간순으로 데이터가 오는데, guard-let을 통과하면서 정렬이 깨집니다.
            // 따라서 sorted()를 이용해, 시간순으로 정렬합니다. - Firebase의 AutoID key 값은 자동으로 시간순 정렬입니다.
            guard let realCommentsList = snapshot.value as? [String:Any] else { return }
            let sortedRealCommentsList = realCommentsList.sorted(by: {$0.key > $1.key} ) // 역시간순(최신순) 정렬 후, 아래 array에서 insert로 아이템 추가.
            
            // 전역 변수에 댓글 데이터를 저장합니다.
            for item in sortedRealCommentsList {
                let oneCommentData = QuoteComment(dicData: item.value as! [String : Any])
                self.commentsList.insert(oneCommentData, at: 0)
                print("///// item(QuoteComment)- 9843: \n", oneCommentData)
            }
            self.commentsList.removeLast(self.currentLastCommentCount)
            self.currentLastCommentCount += Int(lastCount)
            
            print("///// self.commentsList- 9843: \n", self.commentsList)
            
            // 테이블 뷰 전체 리로드
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
                
                // 댓글을 작성하면, 테이블 뷰 맨 아래로 이동합니다.
                if moveToLast {
                    let lastIndexPath = IndexPath(row: self.commentsList.count-1, section: 0)
                    self.mainTableView.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
                }
            }
            
        }) { (error) in
            print("///// error- 9843: \n", error)
        }
        
    }
    
    // MARK: 댓글 좋아요 개수 불러오기
    func findShowCommentsLike() {
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        
        // 댓글 좋아요 카운트는 Firebase에서 별도의 노드를 타고 있어서, 댓글 데이터와는 다른 로직을 타게 됩니다.
        Database.database().reference().child(Constants.firebaseQuoteCommentsLikes).child(realTodayQuoteID).observeSingleEvent(of: DataEventType.value, with: {[unowned self] (snapshot) in
            // 네트워크 인디케이터
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let realCommentsLikesData = snapshot.value as? [String:Any] else { return } // 해당 명언의 댓글 좋아요 개수 전체 데이터 가져오기.
            
            for item in realCommentsLikesData {
                let value = item.value as! [String:Any]
                
                // 좋아요 카운트
                let likesCount = value[Constants.firebaseQuoteCommentsLikesCount] as? Int // 좋아요 카운트 가져오기.
                self.commentsLikeData[item.key] = likesCount ?? 0 // 전역 변수의 좋아요 카운트 Dictionary에 Comment KeyID를 key 값으로 저장.
                
                // 내가 누른 좋아요 여부 확인
                guard let realUid = Auth.auth().currentUser?.uid else { return }
                if let likesData = value[Constants.firebaseQuoteCommentsLikesData] as? [String:Bool] {
                    if likesData[realUid] != nil {
                        self.commentsMyLikeOrNot[item.key] = true // Dictionary에 Comment KeyID를 key 값으로, 내 좋아요 여부를 Bool로 저장.
                    }
                }
            }
            
            // 테이블 뷰 전체 리로드
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
            
        })
    }
    
    // MARK: 댓글 더 보기 버튼 액션 정의
    @IBAction func buttonHeaderMoreCommentsAction(_ sender: UIButton) {
        // 댓글 더 보기 버튼으로 추가 데이터 10개씩을 더 가져오는 로직을 구현하려고 했으나, 댓글 전체(isAllLoad)를 가져오도록 기획을 수정하였습니다. 추후에 10개씩 가져오는 것으로 구현해보기.
        print("///// buttonHeaderMoreCommentsAction- 9723")
        self.findCommentDataToLastOf(isAllLoad: true, lastCount: 0, moveToLast: false)
        sender.isEnabled = false
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
        
        Toast.init(text: "Push to QuoteDev . . . ").show()
        
        self.postCommentData()
    }
    
    // MARK: 댓글 Post Function 정의
    func postCommentData() {
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let realUid = Auth.auth().currentUser?.uid else { return }
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        guard let realUserNickname = self.userNickname else { return }
        
        // 댓글 카운트 데이터, 1 올리기
        let commentsCountRef = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID)
        commentsCountRef.child(Constants.firebaseQuoteCommentsPostsCount).runTransactionBlock({ (currentData) -> TransactionResult in
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
        let postRef = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID)
        let key = postRef.childByAutoId().key
        let post = [Constants.firebaseQuoteCommentsUserUid: realUid,
                    Constants.firebaseQuoteCommentsUserNickname: realUserNickname,
                    Constants.firebaseQuoteCommentsCommentKeyID: key,
                    Constants.firebaseQuoteCommentsCommentCreatedDate: getDateStringOf(date: Date()),
                    Constants.firebaseQuoteCommentsCommentText: self.textFieldWritingComment.text ?? ""]
        let childUpdates = ["/\(Constants.firebaseQuoteCommentsPosts)/\(key)": post]
        postRef.updateChildValues(childUpdates)
        
        // '나의 댓글 명언' 목록 생성을 위한 데이터 삽입
        let userQuotesCommentsdicData:[String:Any] = [realTodayQuoteID:true]
        let userQuotesCommentsRef = Database.database().reference().child(Constants.firebaseUsersRoot).child(realUid).child("user_quotes_comments")
        userQuotesCommentsRef.updateChildValues(userQuotesCommentsdicData)
        
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // Refresh - Data
        self.currentLastCommentCount = 0
        self.commentsList = []
        
        // Refresh - UI
        self.textFieldWritingComment.text = ""
        self.findCommentDataToLastOf(isAllLoad: false, lastCount: 10, moveToLast: true) // 댓글 데이터 가져오기
        self.findShowCommentsLike() // 댓글 좋아요 데이터 가져오기
        self.getCommentsCountAndShowEnableMoreCommentsButton()
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
        self.keyboardHeight = frameEnd.height + 10 // Toast 높이 조절을 위한 전역변수 저장.
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: [.beginFromCurrentState, animationCurve],
            animations: {
                // 기존 코드: 댓글 작성 박스의 constant만 올렸습니다.
                // self.constraintOfViewWritingCommentBox.constant = (self.view.bounds.maxY - self.view.window!.convert(frameEnd, to: self.view).minY)
                
                // 아래 수정 코드: 키보드가 올라오면서 작아진 화면에서 댓글 목록이 자연스럽게 스크롤되도록 self.view의 height를 조정합니다.
                if let realWindow = self.view.window { // self.view.window가 옵셔널이어서 바인딩 처리합니다.
                    self.view.frame.size.height -= (self.view.bounds.maxY - realWindow.convert(frameEnd, to: self.view).minY)
                    self.view.layoutIfNeeded()
                }
                
                self.tapGestureTableViewMain.isEnabled = true // 키보드가 올라왔을 때에만 탭제스쳐를 작동시킵니다.
        },
            completion: nil
        )
    }
    
    //MARK: 댓글 신고 email 보내기 function
    // [주의] `MessageUI` import & MFMailComposeViewControllerDelegate 정의 필요
    func sendReportEmailTo(emailAddress email:String, keyID: String, userNickName: String) {
        let userSystemVersion = UIDevice.current.systemVersion // 현재 사용자 iOS 버전
        let userAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String // 현재 사용자 앱 버전
        
        // 메일 쓰는 뷰컨트롤러 선언
        let mailComposeViewController = configuredMailComposeViewController(emailAddress: email, systemVersion: userSystemVersion, appVersion: userAppVersion!, text1: keyID, text2: userNickName)
        
        // 사용자의 아이폰에 메일 주소가 세팅되어 있을 경우에만 mailComposeViewController()를 태웁니다.
        if MFMailComposeViewController.canSendMail() {
            NotificationCenter.default.removeObserver(self)
            self.present(mailComposeViewController, animated: true, completion: nil)
        } // else일 경우, iOS 에서 자체적으로 메일 주소를 세팅하라는 메시지를 띄웁니다.
    }
    
    // MARK: 메일 보내는 뷰컨트롤러 속성 세팅
    func configuredMailComposeViewController(emailAddress: String, systemVersion: String, appVersion: String, text1: String, text2: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // 메일 보내기 Finish 이후의 액션 정의를 위한 Delegate 초기화.
        
        mailComposerVC.setToRecipients([emailAddress]) // 받는 사람 설정
        mailComposerVC.setSubject("[QuoteDev] Comment's Report") // 메일 제목 설정
        mailComposerVC.setMessageBody("• iOS Version: \(systemVersion) / App Version: \(appVersion)\n• Comment ID: \(text1)\n• User Nickname: \(text2)\n\n◼︎ Report reason: ", isHTML: false) // 메일 내용 설정
        
        return mailComposerVC
    }
    
    // MARK: 댓글 삭제 function
    func deleteCommentData(commentKeyID: String) {
        // 네트워크 인디케이터
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let realTodayQuoteID = self.todayQuoteID else { return }
        
        // 댓글 카운트 데이터, 1 내리기
        let discountCommentRef = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID)
        discountCommentRef.child(Constants.firebaseQuoteCommentsPostsCount).runTransactionBlock({ (currentData) -> TransactionResult in
            guard var postCountData = currentData.value as? Int else { return TransactionResult.success(withValue: currentData) }
            postCountData -= 1
            currentData.value = postCountData
            
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print("///// error- 7234: \n", error.localizedDescription)
            }
        }
        
        // 실제 delete 통신 부분 - 삭제 댓글을 백업 데이터로 이전 시키고, 원본 댓글 데이터는 삭제합니다.
        let deleteRef = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID)
        deleteRef.child(Constants.firebaseQuoteCommentsPosts).child(commentKeyID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            print("///// snapshot- 7832: \n", snapshot.value ?? "(no data)")
            
            // 원본 데이터를 백업 데이터로 이전
            let backupRef = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID)
            backupRef.child(Constants.firebaseQuoteCommentsBackupDeletes).child(commentKeyID).setValue(snapshot.value)
            
            // 원본 데이터 삭제
            let actuallyDeleteRef = Database.database().reference().child(Constants.firebaseQuoteComments).child(realTodayQuoteID)
            actuallyDeleteRef.child(Constants.firebaseQuoteCommentsPosts).child(commentKeyID).removeValue()
            
            // 네트워크 인디케이터
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }) { (error) in
            print("///// error- 7832: \n", error.localizedDescription)
        }
        
        // UI: UI & Data 전체 초기화
        Toast.init(text: "Your comment has been deleted.").show()
        self.currentLastCommentCount = 0
        self.commentsList = []
        self.viewDidLoad()
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
        
        // QuoteCommentTableViewCellDelegate 등록
        cell.delegate = self
        
        // UI
        let str = commentData.commentKeyID
        cell.labelCommentKeyID.text = "# commit: " + str[str.index(after: String.Index.init(encodedOffset: 9))..<str.endIndex] // String 자르기
        cell.labelCommentWriter.text = commentData.userNickname
        cell.labelCommentText.text = commentData.commentText
        cell.labelCommentCreatedDate.text = "// " + commentData.commentCreatedDate
        
        // Data
        cell.todayQuoteID = self.todayQuoteID
        cell.commentKeyID = commentData.commentKeyID
        cell.uid = commentData.userUid
        
        // 댓글 좋아요 카운트 표시 - 댓글 좋아요 카운트의 데이터가 없으면, 0으로 표시합니다. // findShowCommentsLike() 참고
        // Firebase에서 댓글 좋아요 데이터가 다른 노드를 타고 있어서 별도의 function과 로직을 타게 됩니다.
        guard let realCommentLikeCount = self.commentsLikeData[commentData.commentKeyID] else {
            cell.buttonCommentLikeCount.setTitle("0", for: .normal)
            return cell
        }
        
        // 나의 댓글 좋아요 카운트를 별도로 표시 // findShowCommentsLike() 참고
        if let _ = self.commentsMyLikeOrNot[commentData.commentKeyID] {
            cell.buttonCommentLikeCount.setTitle(String(realCommentLikeCount) + " *", for: .normal)
        }else {
            cell.buttonCommentLikeCount.setTitle(String(realCommentLikeCount), for: .normal)
        }
        
        return cell
    }
    
}

// MARK: extension - QuoteCommentTableViewCellDelegate
// 명언 댓글 옵션 버튼 Delegate
extension QuoteCommentViewController: QuoteCommentTableViewCellDelegate {
    func buttonCommentOptionAlert(commentKeyID: String, commentUserUid: String) {
        let alert = UIAlertController(title: nil, message: "You can delete only your comment.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // 삭제 버튼
        let deleteCommentAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) {[unowned self] (action) in
            if Auth.auth().currentUser?.uid == commentUserUid {
                let confirmAlert = UIAlertController(title: "Are you sure you want to delete the comment?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
                    self.deleteCommentData(commentKeyID: commentKeyID)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                
                confirmAlert.addAction(deleteAction)
                confirmAlert.addAction(cancelAction)
                
                self.present(confirmAlert, animated: true, completion: nil)
            }else {
                Toast.init(text: "You can delete only your comment.").show()
            }
        }
        
        // 신고 버튼
        let reportCommentAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive) {[unowned self] (action) in
            guard let realUserNickName = self.userNickname else { return }
            self.sendReportEmailTo(emailAddress: "blackturtle2@gmail.com", keyID: commentKeyID, userNickName: realUserNickName)
        }
        
        // 취소 버튼
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(deleteCommentAction)
        alert.addAction(reportCommentAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: extension - MFMailComposeViewControllerDelegate
extension QuoteCommentViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.addNotificationObserver()
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: extension - UITextFieldDelegate
extension QuoteCommentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 닉네임 Alert TextField 예외처리
        if textField.tag == 0 && string == " " { // 띄어쓰기 금지
            return false
        } else if textField.tag == 0 && range.location > 19 { // 20글자 이상 금지
            return false
        } else {
            return true
        }
    }
}

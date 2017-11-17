//
//  BoardDevWriteViewController.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 9. 27..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Firebase
//  게시판 글쓰기 뷰컨트롤러
class BoardDevWriteViewController: UIViewController {
    // 이미지 여부에 따라 제어하기위한 UIView
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoDeleteBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var reference: DatabaseReference!
    var imageUrlData: URL?
    var textIsEmpty: Bool = true
    let imagePickerController = UIImagePickerController()
    var user_uid: String = "#null"
    var user_nickname = "#null"
    var childCount: Int?
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        textView.delegate = self
        
        // NotificationCenter에 키보드 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(BoardDevWriteViewController.keyboardWillShowHide(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BoardDevWriteViewController.keyboardWillShowHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        // UIButton 자체에 imageInset이 있어서 테스트 해볼예정입니다.
        print("///// userDefaults uid: ", UserDefaults.standard.string(forKey: Constants.userDefaultsUserUid) ?? "no data")
        guard let uid = Auth.auth().currentUser?.uid else {return}
        user_uid = uid
        guard let nickName = UserDefaults.standard.string(forKey: Constants.userDefaultsUserNickname) else {return}
        user_nickname = nickName
        
//        let nowDate = Date()
//        let dateFormatter: DateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyymmddHHmm"
//        let date = dateFormatter.string(from: nowDate)
//        print("DATE:// ", date)
        activityIndicator.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 키보드 옵저버 등록 해제
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*******************************************/
    //MARK:-         IBAction                 //
    /*******************************************/
    // MARK: 앨범 버트 클릭시 호출
    @IBAction func photoBtnTouched(_ sender: UIButton) {
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: 카메라 버튼 클릭시 호출
    @IBAction func cameraBtnTouched(_ sender: UIButton){
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: 전체 스크롤뷰 영역 탭 제스쳐시 호출
    @IBAction func scrollViewTapGesture(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
        if textView.text.isEmpty {
            textView.text = "개발자 이야기를 작성해주세요."
            textView.textColor = UIColor.gray
            textIsEmpty = true
        }
        NotificationCenter.default.post(name: .UIKeyboardWillHide, object: nil)
        
    }
    
    // MARK: 이미지뷰를 담고있는 컨텐츠뷰인 photoView 탭 제스쳐시 호출
    @IBAction func phtotoViewTapGesture(_ sender: UITapGestureRecognizer) {
        print("tap 탭")
        photoImageView.image = nil
        photoView.isHidden = true
    }
    
    // 이미지뷰에 x 버튼 클릭시 호출 - 실기기 테스트통해 탭제스쳐가 호출되어 일단은 연결을 끊어 놓습니다.
    @IBAction func phtoDeleBtnTouched(_ sender: UIButton) {
        print("phtodelete bten 터치")
        
    }
    
    // MARK: 취소버튼 클릭시 호출
    @IBAction func cancelBtnTouched(_ sender: UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: 글 등록 버튼 클릭
    @IBAction func doneBtnTouched(_ sender: UIBarButtonItem){
        // 작성버튼 클릭시 인스턴스 값 할당
        print("글작성 후 확인 벨리데이션://", textIsEmpty)
        print("글작성 후 확인 벨리데이션://", textView.text.isEmpty)
        if !textIsEmpty && !textView.text.isEmpty{
            print("작성가능")
            reference = Database.database().reference()
            
            let nowDate = Date()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let currentDate = dateFormatter.string(from: nowDate)
            let board_uid = "\(user_uid)\(currentDate)"
            print("BoardUID:// ", board_uid)
            print("TEXT://", self.textView.text)
            var imgflag = false
            var img: UIImage?
            let autoID = reference.child("board").child("datas").childByAutoId().key
            guard let textViewText = self.textView.text else { return }
            if let photoImg = self.photoImageView.image {
                imgflag = true
                img = photoImg
                
                self.activityIndicator.isHidden = false
                self.view.backgroundColor = UIColor.black
                self.view.alpha = 0.5
                self.activityIndicator.startAnimating()
                
                // 이미지 저장
                let uploadImg = UIImageJPEGRepresentation(img!, 0.3)
                
                Storage.storage().reference().child("board_img").child(board_uid).putData(uploadImg!, metadata: nil, completion: {[unowned self] (metaData, error) in
                    if let error = error {
                        print("error// ", error)
                        return
                    }
                    
                    print("meta data :  ", metaData ?? "(no data)")
                    guard let urlStr = metaData?.downloadURL()?.absoluteString else{return}
                    
                    self.reference.child("board").runTransactionBlock({ [unowned self] (currentData) -> TransactionResult in
                        
                        //if var datas = currentData.value as? [String:AnyObject]{
                        var currentBoard = currentData.value as? [String:Any] ?? [:]
                        print(currentBoard)
                        var boardCount = currentBoard["board_count"] as? Int ?? 0
                        var boardData =  currentBoard["board_data"] as? [String:Any] ?? [:]
                        
                        var newBoard: [String:Any] = [:]
                        
                        //게시글이 하나 이상일때 증감
                        if boardData.count >= 1{
                            boardCount += 1
                        }
                        
                        newBoard["board_count"] = boardCount
                        
                        
                        var insertData: [String:Any] = [:]
                        insertData.updateValue(board_uid, forKey: "board_uid")
                        insertData.updateValue(textViewText, forKey: "board_text")
                        insertData.updateValue(currentDate, forKey: "board_date") // date형식의경우 계속 시간이 변경됨
                        insertData.updateValue(self.user_uid, forKey: "user_uid")
                        insertData.updateValue(self.user_nickname, forKey: "user_nickname")
                        insertData.updateValue(boardCount, forKey: "board_no") // board_count(고유 글번호)
                        insertData.updateValue(urlStr, forKey: "board_img_url")
                        
                        boardData.updateValue(insertData, forKey: autoID)
                        
                        newBoard["board_data"] = boardData
                        currentData.value = newBoard
                        
                        return TransactionResult.success(withValue: currentData)
                    }) { (error, commit, datasnap) in
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                    }
                })
            }else{
                reference.child("board").runTransactionBlock({[unowned self] (currentData) -> TransactionResult in
                    
                    //if var datas = currentData.value as? [String:AnyObject]{
                    var currentBoard = currentData.value as? [String:Any] ?? [:]
                    print(currentBoard)
                    var boardCount = currentBoard["board_count"] as? Int ?? 0
                    var boardData =  currentBoard["board_data"] as? [String:Any] ?? [:]
                    print("보드 데이터://",boardData)
                    var newBoard: [String:Any] = [:]
                    print("보드 카운트://1:", boardData.count)
                    //게시글이 하나 이상일때 증감
                    if boardData.count >= 1{
                        boardCount += 1
                    }
                    print("보드 카운트://2:", boardData.count)
                    newBoard["board_count"] = boardCount
                    
                    
                    var insertData: [String:Any] = [:]
                    insertData.updateValue(board_uid, forKey: "board_uid")
                    insertData.updateValue(textViewText, forKey: "board_text")
                    insertData.updateValue(currentDate, forKey: "board_date") // date형식의경우 계속 시간이 변경됨
                    insertData.updateValue(self.user_uid, forKey: "user_uid")
                    insertData.updateValue(self.user_nickname, forKey: "user_nickname")
                    insertData.updateValue(boardCount, forKey: "board_no") // board_count(고유 글번호)
                    
                    
                    boardData.updateValue(insertData, forKey: autoID)
                    //boardDatas.updateValue(currentDataDic, forKey: "datas")
                    newBoard["board_data"] = boardData
                    currentData.value = newBoard
                    
                    return TransactionResult.success(withValue: currentData)
                }) { (error, commit, datasnap) in
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }
        }else{
            print("작성불가")
            // UIAlertController 생성
            let alertTextEmpty:UIAlertController = UIAlertController(title: "글 작성", message: "글을 입력해주세요.", preferredStyle: .alert)
            
            // OK 버튼 Action 추가
            alertTextEmpty.addAction(UIAlertAction(title: "확인", style: .cancel, handler: {[unowned self](_) in
                self.textView.becomeFirstResponder()
            }))
            self.present(alertTextEmpty, animated: true, completion: nil)
        }

    }
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: 키보드 올리기 or 내리기 메서드
    func keyboardWillShowHide(notification: Notification){
        // guard-let으로 nil 값이면, 키보드를 내립니다.
        guard let userInfo = notification.userInfo else {
            self.textView.resignFirstResponder() // 키보드 내리기.
            self.footerViewBottomConstraint.constant = 0 // 댓글 작성칸 내리기.
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
                guard let window = self.view.window else {return}
                self.footerViewBottomConstraint.constant = (self.view.bounds.maxY - window.convert(frameEnd, to: self.view).minY)
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
    }
}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension BoardDevWriteViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    /*******************************************/
    //MARK:-      extenstion Functions         //
    /*******************************************/
    // MARK: 이미지 선택시 호출
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 편집 여부에 따라 분기 처리
        print("피커 소스타입:// ", picker.mediaTypes)
        print("이미지 정보: //", info)
        
        // 동영상을 선택한 경우 분기처리
        let mediaType = info["UIImagePickerControllerMediaType"] as! String
        print("미디어 타입://", mediaType)
        
        if mediaType == "public.image"{
            if picker.allowsEditing{
                guard let photoImg = info["UIImagePickerControllerEditedImage"] as? UIImage else {return}
                photoImageView.image = photoImg
            }else{
                guard let cameraImg = info["UIImagePickerControllerOriginalImage"] as? UIImage else {return}
                photoImageView.image = cameraImg
            }
            photoView.isHidden = false
            
            photoImageView.layer.cornerRadius = 20
            self.dismiss(animated: true, completion: nil)
        }else{
            let alertController = UIAlertController(title: "주의", message: "동영상 파일은 첨부하실수 없습니다.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
                
            })
            alertController.addAction(cancelAction)
            imagePickerController.present(alertController, animated: true, completion: nil)
            
        }
    }
    
}

extension BoardDevWriteViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 전역 특정값으로 분기처리
        if textIsEmpty {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        print("TextView textViewDidBeginEditing  호출됨")
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        print("TextView DidEndEditing 호출됨")
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        print("Should End Editing")
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("Did Change")
        if textView.text.isEmpty {
            textIsEmpty = true
        }else{
            textIsEmpty = false
        }
    }
    
    
}


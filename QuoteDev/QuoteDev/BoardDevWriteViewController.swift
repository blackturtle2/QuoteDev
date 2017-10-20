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
    var reference: DatabaseReference!
    var imageUrlData: URL?
    var textIsEmpty: Bool = true
    let imagePickerController = UIImagePickerController()
    var user_uid: String = "#null"
    var user_nickname = "#null"
    var childCount: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        textView.delegate = self
        
        // NotificationCenter에 키보드 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(BoardDevWriteViewController.keyboardWillShowHide(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BoardDevWriteViewController.keyboardWillShowHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        // UIButton 자체에 imageInset이 있어서 테스트 해볼예정입니다.
        print("///// userDefaults uid: ", UserDefaults.standard.string(forKey: Constants.userDefaults_Uid) ?? "no data")
        guard let uid = UserDefaults.standard.string(forKey: Constants.userDefaults_Uid) else {return}
        user_uid = uid
        guard let nickName = UserDefaults.standard.string(forKey: Constants.userDefaults_UserNickname) else {return}
        user_nickname = nickName
        
        let nowDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyymmddHHmm"
        let date = dateFormatter.string(from: nowDate)
        print("DATE:// ", date)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 앨범 버트 클릭시 호출
    @IBAction func photoBtnTouched(_ sender: UIButton) {
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.present(imagePickerController, animated: true, completion: nil)
    }
    // 카메라 버튼 클릭시 호출
    @IBAction func cameraBtnTouched(_ sender: UIButton){
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // 전체 스크롤뷰 영역 탭 제스쳐시 호출
    @IBAction func scrollViewTapGesture(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
        if textView.text.isEmpty {
            textView.text = "개발자 이야기를 작성해주세요."
            textView.textColor = UIColor.gray
            textIsEmpty = true
        }
        NotificationCenter.default.post(name: .UIKeyboardWillHide, object: nil)
        
    }
    
    // 이미지뷰를 담고있는 컨텐츠뷰인 photoView 탭 제스쳐시 호출
    @IBAction func phtotoViewTapGesture(_ sender: UITapGestureRecognizer) {
        print("tap 탭")
        photoImageView.image = nil
        photoView.isHidden = true
    }
    
    // 이미지뷰에 x 버튼 클릭시 호출 - 실기기 테스트통해 탭제스쳐가 호출되어 일단은 연결을 끊어 놓습니다.
    @IBAction func phtoDeleBtnTouched(_ sender: UIButton) {
        print("phtodelete bten 터치")
        
    }
    
    @IBAction func cancelBtnTouched(_ sender: UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneBtnTouched(_ sender: UIBarButtonItem){
        // 작성버튼 클릭시 인스턴스 값 할당
        reference = Database.database().reference()
        let nowDate = Date()
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyymmddHHmm"
        let currentDate = dateFormatter.string(from: nowDate)
        let board_uid = "\(user_uid)\(currentDate)"
        print("BoardUID:// ", board_uid)
        
        print("TEXT://", self.textView.text)
        
        // 현재 board 하위노드에 children 카운트측적을 위한 호출
        reference.child("board").observeSingleEvent(of: .value, with: { (dataSnap) in
            var board_count = 0
            if dataSnap.exists() {
               board_count = Int(dataSnap.childrenCount)
            }
            print(board_count)
            var insertData: [String:Any] = [:]
            insertData.updateValue(board_uid, forKey: "board_uid")
            insertData.updateValue(self.textView.text, forKey: "board_text")
            insertData.updateValue(currentDate, forKey: "board_date") // date형식의경우 계속 시간이 변경됨
            insertData.updateValue(self.user_uid, forKey: "user_uid")
            insertData.updateValue(self.user_nickname, forKey: "user_nickname")
            insertData.updateValue(board_count, forKey: "board_count") // board_count(고유 글번호)
            
            
           
            guard let boardImg = self.photoImageView.image else {return}
            
            let uploadImg = UIImageJPEGRepresentation(boardImg, 0.3)
            // 이미지 저장
            Storage.storage().reference().child("board_img").child(board_uid).putData(uploadImg!, metadata: nil, completion: { (metaData, error) in
                if let error = error {
                    print("error// ", error)
                    return
                }
                
                print("meta data :  ",metaData)
                guard let urlStr = metaData?.downloadURL()?.absoluteString else{return}
                
                insertData.updateValue(urlStr, forKey: "board_img_url")
                self.reference.child("board").childByAutoId().setValue(insertData)
    
                
            })
            
    
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
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
                self.footerViewBottomConstraint.constant = (self.view.bounds.maxY - self.view.window!.convert(frameEnd, to: self.view).minY)
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
    }
}

extension BoardDevWriteViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    // 이미지 선택시 호출
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
            let alertController = UIAlertController(title: "경고", message: "동영상 파일은 첨부하실수 없습니다.", preferredStyle: .alert)
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
        
        textIsEmpty = false
        print(textView.text.isEmpty)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        print("Should End Editing")
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("Did Change")
//        if textView.text.isEmpty {
//            textView.text = "개발자 이야기를 작성해주세요."
//            textView.textColor = UIColor.gray
//            textView.resignFirstResponder()
//        }
    }
    
    
}


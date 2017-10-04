//
//  BoardDevWriteViewController.swift
//  QuoteDev
//
//  Created by HwangGisu on 2017. 9. 27..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

//  게시판 글쓰기 뷰컨트롤러
class BoardDevWriteViewController: UIViewController {
    // 이미지 여부에 따라 제어하기위한 UIView
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoDeleteBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var imageUrlData: URL?
    var textIsEmpty: Bool = true
    let imagePickerController = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        textView.delegate = self
        // UIButton 자체에 imageInset이 있어서 테스트 해볼예정입니다.
        
        
        
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


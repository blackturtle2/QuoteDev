//
//  ViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 9. 14..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet var buttonLike : UIButton! //명언 좋아요 버튼
    @IBOutlet var buttonComment : UIButton! //명언 댓글 버튼

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: 명언 좋아요 버튼 액션
    @IBAction func buttonLikeAction(_ sender: UIButton) {
        
    }

    // MARK: 명언 댓글 버튼 액션
    @IBAction func buttonCommentAction(_ sender: UIButton) {
        
        let alertSetUserNickname:UIAlertController = UIAlertController(title: "닉네임 설정", message: "닉네임을 설정해주세요.", preferredStyle: .alert)
        
        alertSetUserNickname.addTextField { (textField) in
            textField.placeholder = "스티브 잡스"
        }
        
        alertSetUserNickname.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertSetUserNickname] (_) in
            let textField = alertSetUserNickname!.textFields![0] // 위에서 추가한 텍스트필드이므로 옵셔널 바인딩은 스킵.
            print("///// textField: ", textField.text ?? "(no data)")
        }))
        
        self.present(alertSetUserNickname, animated: true, completion: nil)
    }

}


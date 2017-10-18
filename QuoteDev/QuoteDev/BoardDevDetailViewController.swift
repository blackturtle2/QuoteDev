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
    
    var boardData: Board?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("게시판 디테일 뷰디드 로드")
        boardDetailTableView.delegate = self
        boardDetailTableView.dataSource = self
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    // 뷰 컨트롤러 루트 뷰의 경계가 바뀔 때마다 재정의
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("게시판 디테일 뷰 디드 LayouSubView 호출")
        // 현재 테이블 뷰의 헤더뷰 존재 여부 판단
        //guard  let headerView = boardDetailTableView.tableHeaderView as? BoardDevDetailHeaderView else { return }
        
        print(boardData)
        if boardData?.board_img_url != "no-data"{
            print("이미지 존재")
            //boardHeaderView.test = true

        }else{
            print("이미지 없다")
            // 디테일뷰로 넘어올때 이미지 정보가 없을경우 화면에 이미지뷰를 제거하여 priority 설정에 따라 제거후 오토레이아웃 적용
            // 헤더뷰를 다시 그린다.
            boardHeaderView.boardImgView.removeFromSuperview()
            boardHeaderView.setNeedsLayout()
            boardHeaderView.layoutIfNeeded()

        }
        
        
        guard  let boardDatas = boardData else {
            return
        }
        boardHeaderView.boardCotentsLabel.text = boardDatas.board_text
        boardHeaderView.boardCountLabel.text = boardDatas.board_count.description
        boardHeaderView.boardWriterLabel.text = boardDatas.user_nickname
        boardHeaderView.boardCreateAtLabel.text = boardDatas.board_date
        boardHeaderView.boardUID = boardDatas.board_uid
        boardHeaderView.userUID = boardDatas.user_uid
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

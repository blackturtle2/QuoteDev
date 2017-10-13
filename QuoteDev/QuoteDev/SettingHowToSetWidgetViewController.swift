//
//  SettingHowToSetWidgetViewController.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 10. 11..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class SettingHowToSetWidgetViewController: UIViewController {
    
    @IBOutlet weak var scrollViewMain: UIScrollView!
    @IBOutlet weak var pageControlScrollView: UIPageControl!
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollViewMain.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


/*******************************************/
//MARK:-         Extension                 //
/*******************************************/
extension SettingHowToSetWidgetViewController: UIScrollViewDelegate {
    
    // 스크롤이 끝난 후(Did), PageControl의 currentPage를 이동시킵니다.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.x
        let width = Int(self.view.frame.width) // 디스플레이 전체 가로 길이
        let index = Int(currentOffset / self.view.frame.width) // 스크롤 뷰의 현재 x 위치 / 디스플레이의 가로 길이 = 현재 페이지 index 값 도출
        
        if Int(currentOffset) % width == 0 {
            self.pageControlScrollView.currentPage = index
        }
        
    }
}

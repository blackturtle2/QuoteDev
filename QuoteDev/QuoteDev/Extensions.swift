//
//  Extension.swift
//  QuoteDev
//
//  Created by leejaesung on 2017. 12. 6..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    // UIView를 UIImage로 만들어주는 extension
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}

extension String {
    // String에 특정 문자열이 포함되어 있는지 검사하는 extension
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    // String에 소문자/대문자 변환하여 특정 문자열이 포함되어 있는지 검사하는 extension
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

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
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}

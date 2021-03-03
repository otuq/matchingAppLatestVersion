//
//  Extension.swift
//  matchingApp
//
//  Created by USER on 2021/01/22.
//  Copyright © 2021 otuq. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name{
    static let reload = Notification.Name("reload")
}

extension String{
    func textSizeCalc(width: CGFloat,attribute: [NSAttributedString.Key: Any]) -> CGSize{
        let bounds = CGSize(width: width, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin,.usesFontLeading]
        let rect = (self as NSString).boundingRect(with: bounds, options: options, attributes: attribute, context: nil)
        return CGSize(width: rect.size.width, height: rect.size.height)
    }
}

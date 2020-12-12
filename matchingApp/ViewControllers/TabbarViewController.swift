//
//  TabbarViewController.swift
//  matchingApp
//
//  Created by USER on 2020/11/18.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {

    enum ControllerName: Int {
        case search,chat,profile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        viewControllers?.enumerated().forEach({ (index,viewController) in
//            if let name = ControllerName.init(rawValue: index){
//                switch name {
//                case .search:
//                    
//                case .chat:
//                    
//                case .profile:
//                    
//                }
//            }
//        })
        
    }
}

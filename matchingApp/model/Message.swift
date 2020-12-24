//
//  Message.swift
//  matchingApp
//
//  Created by USER on 2020/12/15.
//  Copyright © 2020 otuq. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    let message: String
    
    init(dic: [String: Any]) {
        message = dic["message"]as? String ?? ""
    }
}

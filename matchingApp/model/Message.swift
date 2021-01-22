//
//  Message.swift
//  matchingApp
//
//  Created by USER on 2020/12/15.
//  Copyright © 2020 otuq. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Message {
    
    let name: String
    let message: String
    let uid: String
    let creatAt: Timestamp
    
    init(dic: [String: Any]) {
        name = dic["name"]as? String ?? ""
        message = dic["message"]as? String ?? ""
        uid = dic["uid"]as? String ?? ""
        creatAt = dic["creatAt"]as? Timestamp ?? Timestamp()
    }
}

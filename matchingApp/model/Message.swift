//
//  Message.swift
//  matchingApp
//
//  Created by USER on 2022/1/15.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseFirestore
import Foundation

class Message {
    let name: String
    let message: String
    let uid: String
    let creatAt: Timestamp
    var messageId: String?

    init(dic: [String: Any]) {
        name = dic["name"]as? String ?? ""
        message = dic["message"]as? String ?? ""
        uid = dic["uid"]as? String ?? ""
        creatAt = dic["creatAt"]as? Timestamp ?? Timestamp()
    }
}

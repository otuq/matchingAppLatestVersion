//
//  ChatRoom.swift
//  matchingApp
//
//  Created by USER on 2020/12/15.
//  Copyright © 2020 otuq. All rights reserved.
//

import Foundation
import Firebase

class ChatRoom {
    let members: [String]
    let message: String
    let creatAt: Timestamp
    
    var documentId: String?
    var anotherUser: User?
    
    init(dic: [String: Any]) {
        members = dic["members"]as? [String] ?? []
        message = dic["message"]as? String ?? ""
        creatAt = dic["creatAt"]as? Timestamp ?? Timestamp()
    }
}

//
//  ChatRoom.swift
//  matchingApp
//
//  Created by USER on 2020/12/15.
//  Copyright © 2020 otuq. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ChatRoom {
    let members: [String]
    let latestMessageId: String
    let creatAt: Timestamp
    
    var documentId: String?
    var anotherUser: User?
    var latestMessage: Message?
    var currentUser: User?
    
    init(dic: [String: Any]) {
        members = dic["members"]as? [String] ?? []
        latestMessageId = dic["latestMessageId"]as? String ?? ""
        creatAt = dic["creatAt"]as? Timestamp ?? Timestamp()
    }
}

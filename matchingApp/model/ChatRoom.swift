//
//  ChatRoom.swift
//  matchingApp
//
//  Created by USER on 2022/1/15.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseFirestore
import Foundation

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

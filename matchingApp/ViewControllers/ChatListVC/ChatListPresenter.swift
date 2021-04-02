//
//  ChatListPresenter.swift
//  matchingApp
//
//  Created by USER on 2022/07/26.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol ChatListInput {
    func fetchUserInfo(complition: @escaping (User) -> Void)
    func fetchChatRoom()
}
class ChatListPresenter {
    private weak var output: ChatListOutput!
    private var chatRoomListner: ListenerRegistration?
    init(with output: ChatListOutput) {
        self.output = output
    }
}
extension ChatListPresenter: ChatListInput {
    func fetchUserInfo(complition: @escaping (User) -> Void) {
        Firestore.getUserDocument { user in
            complition(user)
        }
    }
    func fetchChatRoom() {
        chatRoomListner?.remove()
        output.chatRoomRemove()
        // chatRoomsの情報を取得
        chatRoomListner = Firestore.chatRoomAddSnapshotListner(completion: { chatRoom in
            self.addDocumentChange(chatRoom: chatRoom)
        })
    }
    private func addDocumentChange(chatRoom: ChatRoom) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatRoom.members.forEach { anotherUid in
            if uid != anotherUid {
                Firestore.getAnotherUserDocument(documentId: anotherUid) { anotherUser in
                    chatRoom.anotherUser = anotherUser
                    guard let chatRoomId = chatRoom.documentId else { return }
                    let latestMessageId = chatRoom.latestMessageId
                    print("latestmessageId:", latestMessageId)
                    if latestMessageId.isEmpty {
                        self.output.chatRoomAppend(chatRoom: chatRoom)
                        return
                    }
                    Firestore.getLatestMessageDocument(chatRoomId: chatRoomId, latestMessageId: latestMessageId) { message in
                        chatRoom.latestMessage = message
                        self.output.chatRoomAppend(chatRoom: chatRoom)
                    }
                }
            }
        }
    }
}

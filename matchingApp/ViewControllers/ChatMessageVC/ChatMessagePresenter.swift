//
//  ChatMessagePresenter.swift
//  matchingApp
//
//  Created by USER on 2022/07/27.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol ChatMessageInput {
    var uid: String { get }
    func fetchChatRoom(complition: @escaping (_ message: MockMessage) -> Void)
    func sendMessageFirestore(text: String)
}
class ChatMessagePresenter {
    private weak var output: ChatMessageOutput!
    private var messageListner: ListenerRegistration?
    private var chatRoom: ChatRoom?
    init(with output: ChatMessageOutput) {
        self.output = output
        self.chatRoom = output.chatRoomPresent
    }
}
extension ChatMessagePresenter: ChatMessageInput {
    var uid: String { Auth.auth().currentUser?.uid ?? "" }
    func fetchChatRoom(complition: @escaping (_ message: MockMessage) -> Void) {
        messageListner?.remove()
        output.messageListRemove()
        guard let chatRoomId = chatRoom?.documentId else { return }
        messageListner = Firestore.realTimeMessage(chatRoomId: chatRoomId) { message in
            complition(message)
        }
    }
    func sendMessageFirestore(text: String) {
        guard let userName = chatRoom?.currentUser?.name else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let chatRoomId = chatRoom?.documentId else { return }
        let creatAt = Timestamp()
        let messageId = randomString(length: 20)
        let messageData = [
            "name": userName,
            "message": text,
            "uid": uid,
            "creatAt": creatAt
        ]as [String: Any]
        // messageをFirestoreに保存
        Firestore.addMessageInfoFirestore(chatRoomId: chatRoomId, messageId: messageId, data: messageData) { success in
            if success {
                print("メッサージ登録完了")
            }
            let latestMessageData = [
                "latestMessageId": messageId,
                "creatAt": creatAt
            ]as [String: Any]
            // latestMessageのアップデート
            Firestore.updateFirestore(collection: .chatRoom, documentId: chatRoomId, updateData: latestMessageData)
        }
    }
    private func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789"
        let length = UInt32(letters.length)
        var randomString = ""
        for _ in 0..<length {
            let rand = arc4random_uniform(length)
            var char = letters.character(at: Int(rand))
            randomString += NSString(characters: &char, length: 1) as String
        }
        return randomString
    }
}

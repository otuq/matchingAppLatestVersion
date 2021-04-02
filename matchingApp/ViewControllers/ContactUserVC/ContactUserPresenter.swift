//
//  ContactUserPresenter.swift
//  matchingApp
//
//  Created by USER on 2022/07/27.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol ContactUserInput {
    func tapActionMessageButton()
}
class ContactUserPresenter {
    private weak var output: ContactUserOutput!
    private var currentUser: User?
    private var anotherUser: User?
    private var anotherUsers = [String]()
    init(with output: ContactUserOutput) {
        self.output = output
        self.anotherUser = output.anotherUserPresent
        fetchUserInfo()
    }
    private func fetchUserInfo() {
        Firestore.getUserDocument { user in
            self.currentUser = user
        }
    }
}
extension ContactUserPresenter: ContactUserInput {
    func tapActionMessageButton() {
        guard let userUid = Auth.auth().currentUser?.uid,
              let anotherUid = anotherUser?.anotherUid else { return }

        let members = [userUid, anotherUid]
        // 既にchatRoomのあるメンバーと新しくchatRoomを作成する場合を分岐する。
        Firestore.firestore().collection("chatRoom").getDocuments { documents, error in
            if let err = error {
                print("全てのchatRoom情報の取得に失敗しました。", err)
                return
            }
            print("全てのchatRoom情報の取得に成功しました。")
            for snapshot in documents?.documents ?? [] {
                let data = snapshot.data()
                let chatRoom = ChatRoom(dic: data)
                // すでにchatRoomが存在する場合
                if Set(members) == Set(chatRoom.members) {
                    print("メンバーが一致しました。")
                    let storyboard = UIStoryboard(name: "ChatMessage", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "ChatMessageViewController")as! ChatMessageViewController
                    chatRoom.documentId = snapshot.documentID
                    chatRoom.anotherUser = self.anotherUser
                    chatRoom.currentUser = self.currentUser
                    viewController.chatRoom = chatRoom
                    self.anotherUsers = chatRoom.members
                    self.output.transitionChatMessageVC(viewController)
                    break
                }
            }
            // 新規のメンバーとチャットをする場合
            if Set(members) != Set(self.anotherUsers) {
                let uuid = NSUUID().uuidString
                let data = [
                    "members": members,
                    "message": "まだメッセージありません",
                    "creatAt": Timestamp()
                ]as [String: Any]
                self.newChat(uuid: uuid, data: data)
            }
        }
    }
    private func newChat(uuid: String, data: [String: Any]) {
        Firestore.addChatRoomInfoFirestore(documentId: uuid, data: data) { success in
            if success {
                print("chatRoom作成完了")
            }
            Firestore.getChatRoomDocument(chatRoomId: uuid) { chatRoom in
                let storyboard = UIStoryboard(name: "ChatMessage", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ChatMessageViewController")as! ChatMessageViewController
                chatRoom.documentId = uuid
                chatRoom.anotherUser = self.anotherUser
                chatRoom.currentUser = self.currentUser
                viewController.chatRoom = chatRoom
                self.output.transitionChatMessageVC(viewController)
            }
        }
    }
}

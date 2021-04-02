//
//  ExtensionFirebase.swift
//  matchingApp
//
//  Created by USER on 2022/03/25.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PKHUD
import UIKit

// MARK: Auth
extension Auth {
    // 匿名で登録
    static func signInRegister(userInfoArray: [UserInfo: Any?], imageUrl: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signInAnonymously() { authResult, error in
            if let err = error {
                print("認証に失敗しました。", err)
                return
            }
            print("登録に成功しました。")
            guard let user = authResult?.user else { return }
            guard let userName = userInfoArray[.name] as? String,
                  let gender = userInfoArray[.gender] as? String,
                  let age = userInfoArray[.age] as? String,
                  let location = userInfoArray[.location] as? String else { return }
            let uid = user.uid
            let data = [
                "name": userName,
                "gender": gender,
                "age": age,
                "location": location,
                "imageUrl": imageUrl,
                "creatAt": Timestamp(),
                "loginTime": Timestamp(),
                "introduction": "よろしくお願いします。"
            ]as [String: Any]

            Firestore.addInfoFirestore(documentId: uid, data: data) { success in
                completion(success)
            }
        }
    }
}

// MARK: - Firestore
extension Firestore {
    enum Destination: String {
        case user
        case chatRoom
        case message
    }
    // user情報を保存
    static func addInfoFirestore(documentId: String, data: [String: Any], completion: @escaping (Bool) -> Void
    ) {
        Firestore.firestore().collection("user").document(documentId).setData(data) { error in
            if let err = error {
                print("user情報の保存に失敗しました。", err)
                return
            }
            print("user情報の保存に成功しました。")

            completion(true)
        }
    }
    // chatRoom情報を保存
    static func addChatRoomInfoFirestore(documentId: String, data: [String: Any], completion: @escaping (Bool) -> Void
    ) {
        Firestore.firestore().collection("chatRoom").document(documentId).setData(data) { error in
            if let err = error {
                print("chatRoom情報の保存に失敗しました。", err)
                return
            }
            print("chatRoom情報の保存に成功しました。")

            completion(true)
        }
    }
    // message情報の保存
    static func addMessageInfoFirestore(chatRoomId: String, messageId: String, data: [String: Any], completion: @escaping (Bool) -> Void
    ) {
        Firestore.firestore().collection("chatRoom").document(chatRoomId).collection("message").document(messageId).setData(data) { error in
            if let err = error {
                print("message情報の保存に失敗しました。", err)
                return
            }
            print("message情報の保存に成功しました。")

            completion(true)
        }
    }
    // currentUserの情報を取得
    static func getUserDocument(completion: @escaping (User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("user").document(uid).getDocument { snapshot, error in
            if let err = error {
                print("currentUser 情報の取得に失敗しました。", err)
                return
            }
            print("currentUser 情報の取得に成功しました。")
            guard let dic = snapshot?.data() else { return }
            let user = User(dic: dic)
            //            user.anotherUid = snapshot?.documentID
            completion(user)
        }
    }
    // anotherUserの情報を取得
    static func getAnotherUserDocument(documentId: String, complition: @escaping (User) -> Void) {
        Firestore.firestore().collection("user").document(documentId).getDocument { snapshot, error in
            if let err = error {
                print("anotherUser 情報の取得に失敗しました。", err)
                return
            }
            print("anotherUser 情報の取得に成功しました。")
            guard let dic = snapshot?.data() else { return }
            let anotherUser = User(dic: dic)
            anotherUser.anotherUid = snapshot?.documentID
            complition(anotherUser)
        }
    }
    // 全てのanotherUserの情報を取得
    static func getAllAnotherUserDocuments(_ function: @escaping () -> Void, complition: @escaping (User) -> Void) {
        Firestore.firestore().collection("user").getDocuments { snapshots, error in
            if let err = error {
                print("allAnotherUser 情報の取得に失敗しました。", err)
                return
            }
            print("allAnotherUser 情報の取得成功しました。")
            snapshots?.documents.forEach({ snapshot in
                guard let currentUid = Auth.auth().currentUser?.uid else { return }
                if currentUid == snapshot.documentID { return }
                let dic = snapshot.data()
                let anotherUser = User(dic: dic)
                anotherUser.anotherUid = snapshot.documentID
                complition(anotherUser)
            })
            function()
        }
    }
    // chatRoomの情報を取得
    static func getChatRoomDocument(chatRoomId: String, complition: @escaping (ChatRoom) -> Void) {
        Firestore.firestore().collection("chatRoom").document(chatRoomId).getDocument { snapshot, error in
            if let err = error {
                print("chatRoom情報の取得に失敗しました。", err)
                return
            }
            print("chatRoom情報の取得に成功しました。")

            guard let data = snapshot?.data() else { return }
            let chatRoom = ChatRoom(dic: data)
            complition(chatRoom)
        }
    }
    // latestMessageを取得
    static func getLatestMessageDocument(chatRoomId: String, latestMessageId: String, complition: @escaping (Message) -> Void) {
        Firestore.firestore().collection("chatRoom").document(chatRoomId).collection("message").document(latestMessageId).getDocument { snapshot, error in
            if let err = error {
                print("最新メッセージの取得に失敗しました。", err)
            }
            print("最新メッセージの取得に成功しました。")
            guard let data = snapshot?.data() else { return }
            let messageData = Message(dic: data)

            complition(messageData)
        }
    }
    // chatRoom情報をリアルタイムに取得
    static func chatRoomAddSnapshotListner(completion: @escaping (ChatRoom) -> Void) -> ListenerRegistration {
        Firestore.firestore().collection("chatRoom").addSnapshotListener { snapshot, error in
            if let err = error {
                print("chatRoom情報のリアルタイム取得に失敗しました。", err)
                return
            }
            print("chatRoom情報のリアルタイム取得に成功しました。")

            snapshot?.documentChanges.forEach({ documentChange in
                switch documentChange.type {
                case .added:
                    let data = documentChange.document.data()
                    let chatRoom = ChatRoom(dic: data)

                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    // 自分がメンバーに含まれていないchatRoomの情報を取得しない
                    if !chatRoom.members.contains(uid) { return }

                    chatRoom.documentId = documentChange.document.documentID
                    completion(chatRoom)
                // latestmessageが更新された時に呼び出される
                case .modified:
                    print("modified")
                    NotificationCenter.default.post(name: .latestMessageUpdate, object: nil)
                case .removed:
                    print("nothing to do")
                }
            })
        }
    }
    // message情報をリアルタイムに取得
    static func messageAddSnapshotListner(chatRoomId: String, completion: @escaping (DocumentChange) -> Void) -> ListenerRegistration {
        Firestore.firestore().collection("chatRoom").document(chatRoomId).collection("message").addSnapshotListener { snapshot, error in
            if let err = error {
                print("message情報のリアルタイム取得に失敗しました。", err)
                return
            }
            print("message情報のリアルタイム取得に成功しました。")
            snapshot?.documentChanges.forEach({ documentChange in
                switch documentChange.type {
                case .added:
                    completion(documentChange)
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    // messageをリアルタイムで取得
    static func realTimeMessage(chatRoomId: String, complition: @escaping (MockMessage) -> Void) -> ListenerRegistration {
        Firestore.messageAddSnapshotListner(chatRoomId: chatRoomId) { documentChange in
            let messageId = documentChange.document.documentID
            let dic = documentChange.document.data()
            let message = Message(dic: dic)
            let sender = Sender(senderId: message.uid, displayName: message.name )
            let mockMessage = MockMessage(text: message.message, sender: sender, messageId: messageId, date: message.creatAt.dateValue())

            complition(mockMessage)
        }
    }
    // Firestoreへのupdate
    static func updateFirestore(collection: Destination, documentId: String, updateData: [AnyHashable: Any], completion: (() -> Void)? = nil ) {
        Firestore.firestore().collection(collection.rawValue).document(documentId).updateData(updateData) { error in
            if let err = error {
                print("Firestoreへのアップデートに失敗しました。", err)
                return
            }
            print("Firestoreへのアップデートに成功しました。")

            if let c = completion {
                c()
            }
        }
    }
}

// MARK: - Storage
extension Storage {
    // StorageにimageDataを保存
    static func addImageStorage(uuidString: String, jpgData: Data, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_image").child(uuidString)
        storageRef.putData(jpgData, metadata: nil) { _, error in
            if let err = error {
                print("storageへの保存に失敗しました。", err)
                return
            }
            storageRef.downloadURL { url, error in
                if let err = error {
                    print("urlの取得に失敗しました。", err)
                }
                print("urlの取得に成功しました。")
                // URL型をStringに変換
                guard let urlString = url?.absoluteString else { return }
                completion(urlString)
            }
        }
    }
    // Storageへupdate
    static func updataImageUrl(jpgData: Data, child: String, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_image").child(child)
        storageRef.putData(jpgData, metadata: nil) { _, error in
            if let err = error {
                print("storageへのアップデートに失敗しました。", err)
                return
            }
            print("storageへのアップデートに成功しました。")
            storageRef.downloadURL { url, error in
                if let err = error {
                    print("ダウンロードurlの取得に失敗しました。", err)
                    return
                }
                print("ダウンロードurlの取得に成功しました。")
                guard let urlString = url?.absoluteString else { return }
                completion(urlString)
            }
        }
    }
}

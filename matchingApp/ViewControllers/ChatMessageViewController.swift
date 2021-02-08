//
//  ChatMessageViewController.swift
//  matchingApp
//
//  Created by USER on 2020/12/16.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseAuth
import Nuke

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

class ChatMessageViewController: MessagesViewController {
    
    private var user: User?
    private var messageListner: ListenerRegistration?
    private lazy var messageList = [MockMessage]()
    var chatRoom: ChatRoom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserInfo()
        fetchChatRoomInfo()
        messageKitSetting()
        //メッセージを開いた時最新メッセージまでスクロール　非同期処理する必要があるみたい
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    private func messageKitSetting(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
    }
    private func fetchUserInfo(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("user").document(uid).getDocument { (snapshot, error) in
            if let err = error{
                print("ユーザー情報の取得に失敗しました。",err)
                return
            }
            guard let dic = snapshot?.data() else { return }
            let user = User(dic: dic)
            self.user = user
        }
    }
    private func fetchChatRoomInfo(){
        
        messageListner?.remove()
        messageList.removeAll()
        messagesCollectionView.reloadData()
        
        guard let chatRoomId = chatRoom?.documentId else { return }
        messageListner = Firestore.firestore().collection("chatRooms").document(chatRoomId).collection("messages").addSnapshotListener { (snapshot, error) in
            if let err = error{
                print("メッセージ情報の取得に失敗しました。",err)
                return
            }
            print("メッセージ情報の取得に成功しました。")
            snapshot?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type{
                case .added:
                    let messageId = documentChange.document.documentID
                    let dic = documentChange.document.data()
                    let message = Message.init(dic: dic)
                    let sender = Sender(senderId: message.uid, displayName: message.name)
                    let mockMessage = MockMessage(text: message.message, sender: sender, messageId: messageId, date: message.creatAt.dateValue())
                    self.messageList.append(mockMessage)
                    self.messagesCollectionView.reloadData()
                case .modified,.removed:
                    print("nothing to do")
                    return
                }
            })
        }
    }
}
//MARK: -MessagesDataSource
extension ChatMessageViewController: MessagesDataSource{
    //自身の情報を設定する
    func currentSender() -> SenderType {
        if let uid = Auth.auth().currentUser?.uid{
            return Sender(senderId: uid, displayName: user?.name ?? "")
        }
        return currentSender()
    }
    
    //indexpathでメッセージの中身を呼び出す
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messageList.sort { (m1, m2) -> Bool in
            let sort1 = m1.sentDate
            let sort2 = m2.sentDate
            return sort1 < sort2
        }
        return messageList[indexPath.section]
    }
    //表示するメッセージの数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),.foregroundColor: UIColor(white: 0.3, alpha: 1.0)])
    }
}
//MARK: -MessageCellDelegate
extension ChatMessageViewController: MessageCellDelegate{
    //メッセージをタップした時の処理
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("tapMessage")
    }
}
//MARK: -MessagesDisplayDelegate
extension ChatMessageViewController: MessagesDisplayDelegate{
    //メッサージの色を変更
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white: .darkGray
    }
    //メッセージの背景色を変更
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemBlue: .systemPink
    }
    //メッセージのしっぽ
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    //アイコンのセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let url = URL(string: user?.imageUrl ?? "") else { return }
        Nuke.loadImage(with: url, into: avatarView)
        
//        guard let imageData = try? Data(contentsOf: url) else { return }
//        let image = UIImage(data: imageData)
//        let avatar = Avatar(image: image, initials: message.sender.displayName)
        
    }
}
//MARK: -MessagesLayoutDelegate
extension ChatMessageViewController: MessagesLayoutDelegate{
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}
//MARK: -InputBarAccessoryViewDelegate
extension ChatMessageViewController: InputBarAccessoryViewDelegate{
    
    //送信ボタンを押した時の処理
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendMessageFirestore(text: text)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom()
    }
    private func sendMessageFirestore(text: String){
        
        guard let userName = user?.name else { return }
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
        
        Firestore.firestore().collection("chatRooms").document(chatRoomId).collection("messages").document(messageId).setData(messageData) { (error) in
            if let err = error{
                print("メッサージ情報の保存に失敗しました。",err)
                return
            }
            
            let message = MockMessage(text: text, sender: self.currentSender(), messageId: messageId, date: creatAt.dateValue())
            self.messageList.append(message)
            
            let latestMessageData = [
                "latestMessageId": messageId,
                "creatAt": creatAt
            ]as [String: Any]
            Firestore.firestore().collection("chatRooms").document(chatRoomId).updateData(latestMessageData) { (error) in
                if let err = error{
                    print("最新メッサージ情報のアップデートに失敗しました。",err)
                    return
                }
                print("最新メッセージ情報の保存に成功しました。")
                //Notification.Nameを拡張して通知名を追加する。下記のコードで通知を投稿する。リロードするChatListViewControllerにaddObserverを追加する。
                NotificationCenter.default.post(name: .reload, object: nil)
            }
        }
    }
}
private func randomString(length: Int)->String{
    let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789"
    let length = UInt32(letters.length)
    var randomString = ""
    for _ in 0..<length{
        let rand = arc4random_uniform(length)
        var char = letters.character(at: Int(rand))
        randomString += NSString(characters: &char, length: 1) as String
    }
    return randomString
}


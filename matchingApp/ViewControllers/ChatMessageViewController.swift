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

class ChatMessageViewController: MessagesViewController {
    
    private var user: User?
    var chatRoom: ChatRoom?
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageKitSetting()
        fetchUserInfo()
    }
    
    private func messageKitSetting(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
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
        return messages[indexPath.section] as! MessageType
    }
    //表示するメッセージの数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
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
        return isFromCurrentSender(message: message) ? .systemGray: .systemPink
    }
    //メッセージのしっぽ
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomLeft: .bottomRight
        return .bubbleTail(corner, .curved)
    }
    //アイコンのセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let url = URL(string: user?.imageUrl ?? "") else { return }
        guard let imageData = try? Data(contentsOf: url) else { return }
        let image = UIImage(data: imageData)
        let avatar = Avatar(image: image, initials: message.sender.displayName)
        avatarView.set(avatar: avatar)
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
        messagesCollectionView.scrollToBottom()
    }
    private func sendMessageFirestore(text: String){
                
        guard let userName = user?.name else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let chatRoomId = chatRoom?.documentId else { return }
        
        let messageId = randomString(length: 20)
        
        let messageData = [
            "name": userName,
            "message": text,
            "uid": uid,
            "creatAt": Timestamp()
        ]as [String: Any]
        
        Firestore.firestore().collection("chatRooms").document(chatRoomId).collection("messages").document(messageId).setData(messageData) { (error) in
            if let err = error{
                print("メッサージ情報の保存に失敗しました。",err)
                return
            }
            
            let latestMessageData = [
                "latestMessageId": messageId
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


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
import Firebase
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
extension ChatMessageViewController: MessageCellDelegate{
    //メッセージをタップした時の処理
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("tapMessage")
    }
}
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
extension ChatMessageViewController: InputBarAccessoryViewDelegate{
    //送信ボタンを押した時の処理
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendMessageFirestore(text: text)
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom()
    }
    private func sendMessageFirestore(text: String){
        
    }
}

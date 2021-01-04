//
//  ContactUserViewController.swift
//  matchingApp
//
//  Created by USER on 2020/12/14.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class ContactUserViewController: UIViewController {
    
    var anotherUser: User?
    var anotherMember: [String]?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingView()
        userInfoUISetting()
    }
    private func settingView(){
        userImageView.layer.cornerRadius = userImageView.bounds.width/2
        userImageView.contentMode = .scaleAspectFill
        messageButton.addTarget(self, action: #selector(tapActionMessageButton), for: .touchUpInside)
    }
    @objc private func tapActionMessageButton(){
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        guard let anotherUid = anotherUser?.anotherUid else { return }
        let members = [userUid,anotherUid]
        let uuid = NSUUID().uuidString
        let data = [
            "members": members,
            "message": "まだメッセージありません",
            "creatAt": Timestamp()
        ]as [String: Any]
        //既に同じメンバーのchatRoomがある場合と新規で条件分岐させる。
        Firestore.firestore().collection("chatRooms").getDocuments { (documents, error) in
            if let err = error{
                print("chatRooms情報の取得に失敗しました。",err)
                return
            }
            documents?.documents.forEach({ (snapshot) in
                let data = snapshot.data()
                let chatRoom = ChatRoom(dic: data)
                if Set(members).isSubset(of: Set(chatRoom.members)){
                    let storyboard = UIStoryboard.init(name: "ChatMessage", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "ChatMessageViewController")as! ChatMessageViewController
                    viewController.chatRoom = chatRoom
                    self.anotherMember = chatRoom.members
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            })
        }
        if !Set(members).isSubset(of: anotherMember ?? [String]()){
            newChat(uuid: uuid, data: data)
        }
    }
    private func newChat(uuid: String,data: [String: Any]){
        Firestore.firestore().collection("chatRooms").document(uuid).setData(data) { (error) in
            if let err = error{
                print("chatRoom情報の保存に失敗しました。",err)
                return
            }
            print("chatRoom情報の保存に成功しました。")
            Firestore.firestore().collection("chatRooms").document(uuid).getDocument { (snapshot, error) in
                if let err = error{
                    print("chatRoom情報の取得に失敗しました。",err)
                    return
                }
                guard let data = snapshot?.data() else { return }
                
                let storyboard = UIStoryboard.init(name: "ChatMessage", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ChatMessageViewController")as! ChatMessageViewController
                let chatRoom = ChatRoom(dic: data)
                chatRoom.documentId = uuid
                viewController.chatRoom = chatRoom
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    private func userInfoUISetting(){
        guard let anotherUser = anotherUser else { return }
        self.usernameLabel.text = anotherUser.name
        self.userInfoLabel.text = "\(anotherUser.location)/\(anotherUser.gender)/\(anotherUser.age)"
        if let urlString = URL(string: anotherUser.imageUrl){
            Nuke.loadImage(with: urlString, into: userImageView)
        }
    }
}

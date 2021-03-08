//
//  ChatListViewController.swift
//  matchingApp
//
//  Created by USER on 2020/12/23.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatListViewController: UIViewController {

    let cellId = "cellId"
    private var user: User?
    var chatRooms = [ChatRoom]()
    private var chatRoomListner: ListenerRegistration?
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        fetchChatRoom()
        fetchUserInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(latestMessageUpdate), name: .latestMessageUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signUpLoad), name: .signUpLoad, object: nil)
        //profile情報を更新したら通知される
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdate), name: .profileUpdate, object: nil)
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
    @objc private func profileUpdate(){
        //profileで更新した情報を取得してreloadをしてchatMeesageVCへ値を渡して更新する。
        fetchUserInfo()
        chatListTableView.reloadData()
    }
    @objc private func signUpLoad(){
        fetchChatRoom()
    }
    @objc private func latestMessageUpdate(){
        fetchChatRoom()
    }
    private func settingView(){
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }
    func fetchChatRoom(){
        //chatRoomsListnerは最終的にはいらなくなると思う。Logoutをしない仕様のアプリだから
        chatRoomListner?.remove()
        chatRooms.removeAll()
        chatListTableView.reloadData()
       chatRoomListner = Firestore.firestore().collection("chatRooms").addSnapshotListener { (snapshot, error) in
            if let err = error{
                print("chatRoomの情報の取得に失敗しました。",err)
                return
            }
            print("chatRoomの情報の取得に成功しました。ok")
            snapshot?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type{
                case .added:
                    self.addDocumentChange(documentChange: documentChange)
                case .modified,.removed:
                    print("nothing to do")
                }
            })
        }
    }
    private func addDocumentChange(documentChange: DocumentChange){
        let data = documentChange.document.data()
        let chatRoom = ChatRoom.init(dic: data)
        chatRoom.documentId = documentChange.document.documentID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if !chatRoom.members.contains(uid){ return }
        chatRoom.members.forEach { (anotherUid) in
            if uid != anotherUid{
                Firestore.firestore().collection("user").document(anotherUid).getDocument { (snapshot, error) in
                    if let err = error {
                        print("パートナーUserの情報の取得に失敗しました。",err)
                    }
                    print("パートナーUserの情報の取得に成功しました。")
                    guard let data = snapshot?.data() else { return }
                    let anotherUser = User.init(dic: data)
                    anotherUser.anotherUid = snapshot?.documentID
                    chatRoom.anotherUser = anotherUser
                    guard let chatRoomId = chatRoom.documentId else { return }
                    let latestMessageId = chatRoom.latestMessageId
                    if latestMessageId.isEmpty{
                        self.chatRooms.append(chatRoom)
                        self.chatListTableView.reloadData()
                        return
                    }
                    Firestore.firestore().collection("chatRooms").document(chatRoomId).collection("messages").document(latestMessageId).getDocument { (snapshot, error) in
                        if let err = error{
                            print("最新メッセージの取得に失敗しました。",err)
                        }
                        print("最新メッセージの取得に成功しました。")
                        guard let data = snapshot?.data() else { return }
                        let messageData = Message.init(dic: data)
                        chatRoom.latestMessage = messageData
                        self.chatRooms.append(chatRoom)
                        self.chatListTableView.reloadData()
                    }
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        self.didReceiveMemoryWarning()
    }
}
//MARK: -UITableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId)as! ChatListTableViewCell
        self.chatRooms.sort { (s1, s2) -> Bool in
            let sort1 = s1.creatAt.dateValue()
            let sort2 = s2.creatAt.dateValue()
            return sort1 > sort2
        }
        cell.chatRoom = chatRooms[indexPath.row]
        cell.chatRoom?.currentUser = self.user
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ChatMessage", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ChatMessageViewController")as! ChatMessageViewController
        viewController.chatRoom = chatRooms[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

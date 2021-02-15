//
//  SearchViewController.swift
//  matchingApp
//
//  Created by USER on 2020/11/18.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

//protocol LogoutButton: class {
//    func tapActionReload()
//}

class SearchViewController: UIViewController {
    
    private let cellId = "cellId"
    private let cellColums: CGFloat = 2
    //絞り込み検索で使う
    var duplicateAnotherUsers: [User]?
    var anotherUsers = [User]()
//    private var anotherUserListener:
    private let refreshCtrl = UIRefreshControl()
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    @IBAction func logoutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.whenNewUser(logoutBool: true)
        }catch{
            print(error)
        }
    }
    @IBAction func narrowdownBUtton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "NarrowDown", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "NarrowDownViewController")
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        whenNewUser(logoutBool: false)
        delegateSetting()
        viewSetting()
        fetchUserInfo()
        refreshSetting()
    }
    //下にスワイプしてリロード
    private func refreshSetting(){
        searchCollectionView.refreshControl = refreshCtrl
        refreshCtrl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    
    @objc private func refresh(sender: UIRefreshControl){
        fetchUserInfo()
        searchCollectionView.reloadData()
        sender.endRefreshing()
    }
    
    func fetchUserInfo(){
        anotherUsers.removeAll()
        Firestore.firestore().collection("user").getDocuments { (snapshot, error) in
            if let err = error{
                print("他ユーザーの情報の取得に失敗しました。",err)
                return
            }
            print("他ユーザーの情報の取得成功しました。")
                        
            snapshot?.documents.forEach({ (document) in
                guard let currentUid = Auth.auth().currentUser?.uid else { return }
                if currentUid == document.documentID { return }
                let dic = document.data()
                let anotherUser = User(dic: dic)
                anotherUser.anotherUid = document.documentID
                self.anotherUsers.append(anotherUser)
                self.duplicateAnotherUsers = self.anotherUsers
                self.searchCollectionView.reloadData()
            })
        }
    }
    
    func delegateSetting(){
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        let customLayout = CustomLayout()
        customLayout.delegate = self
        searchCollectionView.collectionViewLayout = customLayout
    }
    
    private func viewSetting(){
        searchCollectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    private func whenNewUser(logoutBool: Bool){
        if Auth.auth().currentUser?.uid == nil{
            let storyboard = UIStoryboard.init(name: "StartUp", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "StartUpViewController")as! StartUpViewController
            viewController.logoutBool = logoutBool
            let nav = UINavigationController.init(rootViewController: viewController)
            nav.modalPresentationStyle = .fullScreen
            nav.setNavigationBarHidden(true, animated: true)
            self.present(nav, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return anotherUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)as! SearchCollectionViewCell
        anotherUsers.sort { (s1, s2) -> Bool in
            let sortDate1 = s1.creatAt.dateValue()
            let sortDate2 = s2.creatAt.dateValue()
            return sortDate2 < sortDate1
        }
        cell.anotherUser = anotherUsers[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ContactUser", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ContactUserViewController")as! ContactUserViewController
        viewController.anotherUser = anotherUsers[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = self.view.frame.width/cellColums
//        let height = CGFloat.random(in: 200...400)
//        return CGSize(width: width, height: height)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
    
}

extension SearchViewController: CustomDelegate{
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        return CGFloat.random(in: 200...400)
    }
}

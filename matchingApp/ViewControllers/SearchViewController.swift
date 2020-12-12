//
//  SearchViewController.swift
//  matchingApp
//
//  Created by USER on 2020/11/18.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {
    
    private let cellId = "cellId"
    private let cellColums: CGFloat = 2
    private var anotherUsers = [User]()
//    private var anotherUserListener:
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    @IBAction func logoutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.whenNewUser()
        }catch{
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        whenNewUser()
        viewSetting()
        fetchUserInfo()
    }
    
    func fetchUserInfo(){
        anotherUsers.removeAll()
        Firestore.firestore().collection("user").getDocuments { (snapshot, error) in
            if let err = error{
                print("他ユーザーの情報の取得に失敗しました。",err)
            }
            print("他ユーザーの情報の取得成功しました。")
                        
            snapshot?.documents.forEach({ (document) in
                guard let currentUid = Auth.auth().currentUser?.uid else { return }
                if currentUid == document.documentID { return }
                let dic = document.data()
                let anotherUser = User(dic: dic)
                anotherUser.anotherUid = document.documentID
                self.anotherUsers.append(anotherUser)
                self.searchCollectionView.reloadData()
            })
        }
    }
    
    private func viewSetting(){
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    private func whenNewUser(){
        if Auth.auth().currentUser?.uid == nil{
            let storyboard = UIStoryboard.init(name: "StartUp", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "StartUpViewController")
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
        cell.anotherUser = anotherUsers[indexPath.row]
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        <#code#>
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width/cellColums
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

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

class SearchViewController: UIViewController {
    
    private let cellId = "cellId"
    private let cellColums: CGFloat = 2
    private let refreshCtrl = UIRefreshControl()
    private let userdefaults = UserDefaults.standard
    //絞り込み検索で使う
    var duplicateAnotherUsers: [User]?
    var anotherUsers = [User]()
    var cells = [CGFloat]()
    //アプリ起動時一度だけ実行するクロージャ
    private var executeOnce = {}
    typealias ExecuteOnce = ()->()
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBAction func logoutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.whenNewUser(judgment: true)
        }catch{
            print(error)
        }
    }
    @IBAction func narrowDownButton(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "NarrowDown", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "NarrowDownViewController")
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        executeOnce()
        whenNewUser(judgment: false)
        viewSetting()
        fetchUserInfo()
        delegateSetting()
        refreshSetting()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //アプリを起動したログイン時間を保存する。
        executeOnce = loginTimeGet {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let updateData = ["loginTime": Timestamp()]as [String: Any]
            Firestore.firestore().collection("user").document(uid).updateData(updateData) { (error) in
                if let err = error{
                    print("ログインタイムのアップデートに失敗しました。",err)
                    return
                }
            }
        }
    }
    //@escapingを記述しないとエラーが起こる。いまいち理由がわからないけど。Escaping closure captures non-escaping parameter 'execute'
    private func loginTimeGet(execute: @escaping()->()) -> ExecuteOnce{
        var once = true
        return {
            if once{
                once = false
                execute()
            }
        }
    }
    //下にスワイプしてリロード
    private func refreshSetting(){
        searchCollectionView.refreshControl = refreshCtrl
        refreshCtrl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    @objc private func refresh(sender: UIRefreshControl){
        viewDidLoad()
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
            })
            //データの取得を完了した後に行わないと意味がないのでFirebaseのスコープ内に絞り込みのコードを書く。
            guard let formValues = self.userdefaults.object(forKey: "form")as? [String: Any] else { return }
            let values = User.init(dic: formValues)
            self.anotherUsers = values.gender != "未設定" ? self.anotherUsers.filter({$0.gender == values.gender}): self.anotherUsers
            self.anotherUsers = values.age != "未設定" ? self.anotherUsers.filter({$0.age == values.age}): self.anotherUsers
            self.anotherUsers = values.location != "未設定" ? self.anotherUsers.filter({$0.location == values.location}): self.anotherUsers
            self.searchCollectionView.reloadData()
        }
    }
    func delegateSetting(){
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        //CustomLayout.swiftファイルでカスタムレイアウトを作成
        let customLayout = CustomLayout()
        customLayout.delegate = self
        self.searchCollectionView.collectionViewLayout = customLayout
    }
    private func viewSetting(){
        searchCollectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    private func whenNewUser(judgment: Bool){
        if Auth.auth().currentUser?.uid == nil{
            let storyboard = UIStoryboard.init(name: "StartUp", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "StartUpViewController")as! StartUpViewController
            viewController.logoutJudgment(judgment: judgment)
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
        
        print("homohomo")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ContactUser", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ContactUserViewController")as! ContactUserViewController
        viewController.anotherUser = anotherUsers[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchViewController: CustomDelegate{
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, contentWidth: CGFloat) -> CGFloat {
        //layoutのframeが先でその後にcellForItemAtのデリゲートメソッドにいく。
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)as! SearchCollectionViewCell
        anotherUsers.sort { (s1, s2) -> Bool in
            let sortDate1 = s1.creatAt.dateValue()
            let sortDate2 = s2.creatAt.dateValue()
            return sortDate2 < sortDate1
        }
        let userData = anotherUsers[indexPath.row]
        var text = ""
        for _ in 0...20{
            text += userData.name
        }
        //cellのプロパティにデータを与えてそれを元に高さを求めることは難しいかできないみたいだから、高さが可変するtextViewに入れる文字列を計算してcellの高さを決める。
        //
        let attributes: [NSAttributedString.Key: Any] = [.font : cell.userMessageTextView.font as Any]
        let textPadding = cell.userMessageTextView.textContainer.lineFragmentPadding * 2
        //Stringを拡張して文字列の幅と高さを計算する。文字列の実際の幅を計算するためtextViewのpaddingを引いて計算。
        let messageHeight = text.textSizeCalc(width: contentWidth - textPadding, attribute: attributes)
        //他のUIKitとmargin、textViewのpaddingを計算する。
        let fixedHeight = cell.topStackView.bounds.height + cell.userLoginTime.bounds.height + 10 + 20
        let height = messageHeight.height + fixedHeight

        return height
    }
}

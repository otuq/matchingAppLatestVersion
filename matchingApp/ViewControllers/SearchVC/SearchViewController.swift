//
//  SearchViewController.swift
//  matchingApp
//
//  Created by USER on 2022/1/18.
//  Copyright © 2022 otuq. All rights reserved.
//

import UIKit

protocol SearchOutput: AnyObject {
    func transitionSignUpVC()
    func narrowDownData()
}
class SearchViewController: UIViewController {
    // MARK: properties
    private let cellId = "cellId"
    private let cellColums: CGFloat = 2
    private let refreshCtrl = UIRefreshControl()
    private let userDefaults = UserDefaults.standard
    private var executeOnce = {} // アプリ起動時一度だけ実行する
    private var presenter: SearchPresenter!
    typealias ExecuteOnce = () -> Void
    var anotherUsers = [User]()
    var duplicateAnotherUsers: [User]? // 絞り込み検索で使う

    // MARK: - Outlets & Actions
    @IBOutlet var searchCollectionView: UICollectionView!
    @IBAction func logoutButton(_ sender: Any) {
        presenter.authSignout()
    }
    // 絞り込み検索
    @IBAction func narrowDownButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "NarrowDown", bundle: nil)
        let viewcontroller = storyboard.instantiateViewController(withIdentifier: "NarrowDownViewController")
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        executeOnce()
        whenNewUser()
        settingView()
        fetchAnotherUsersInfo()
        settingDelegate()
        refreshSetting()
    }
    private func initialize() {
        presenter = SearchPresenter(with: self)
    }
    // userが新規の場合登録画面に遷移する。
    private func whenNewUser() {
        presenter.whenNewUser()
    }
    private func settingView() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "backgroundimage")!
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
        imageView.anchor(top: searchCollectionView.topAnchor, bottom: searchCollectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        navigationItem.title = "話し相手を探す"
    }
    func settingDelegate() {
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        let customLayout = CustomLayout()
        customLayout.delegate = self
        self.searchCollectionView.collectionViewLayout = customLayout
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // アプリを起動したログイン時間を保存する。
        executeOnce = loginTimeGet {
            self.presenter.authSignIn()
        }
    }
    private func startUpView() {
        // アプリ起動時に全てのタブビューのviewを描画する
        tabBarController?.viewControllers?.forEach({ viewController in
            let view = viewController.view
            view?.layoutSubviews()
        })
    }
    private func loginTimeGet(execute: @escaping () -> Void) -> ExecuteOnce {
        var once = true
        return {
            if once {
                once = false
                self.startUpView()
                print("once")
                execute()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // 下にスワイプしてリロード
    private func refreshSetting() {
        searchCollectionView.refreshControl = refreshCtrl
        refreshCtrl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    @objc private func refresh(sender: UIRefreshControl) {
        fetchAnotherUsersInfo()
        sender.endRefreshing()
    }
    private func fetchAnotherUsersInfo() {
        self.anotherUsers.removeAll()
        self.presenter.fetchAnotherUserInfo { anotherUser in
            self.anotherUsers.append(anotherUser)
            self.duplicateAnotherUsers = self.anotherUsers
            print("userSCount", self.anotherUsers.count)
        }
    }
}
// MARK: - Presenter
extension SearchViewController: SearchOutput {
    func transitionSignUpVC() {
        let storyboard = UIStoryboard(name: "StartUp", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "StartUpViewController")as! SignUpViewController
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    func narrowDownData() {
        guard let formValues = self.userDefaults.object(forKey: "form")as? [String: Any] else { return }
        let values = User(dic: formValues)
        anotherUsers = values.gender != "未設定" ? anotherUsers.filter({ $0.gender == values.gender }): anotherUsers
        anotherUsers = values.age != "未設定" ? anotherUsers.filter({ $0.age == values.age }): anotherUsers
        anotherUsers = values.location != "未設定" ? anotherUsers.filter({ $0.location == values.location }): anotherUsers
        searchCollectionView.reloadData()
        print("narrowDown")
    }
}
// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Userdefaultsに保存されている検索ワードを取得して起動時に絞り込みを行う。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("anotherUsers", anotherUsers.count)
        return anotherUsers.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)as! SearchCollectionViewCell
        cell.anotherUser = anotherUsers[indexPath.row]

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ContactUser", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ContactUserViewController")as! ContactUserViewController
        viewController.anotherUser = anotherUsers[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}
// MARK: - CustomLayout
extension SearchViewController: CustomDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, contentWidth: CGFloat) -> CGFloat {
        // layoutのframeが先でその後にcellForItemAtのデリゲートメソッドにいく。
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)as! SearchCollectionViewCell
        anotherUsers.sort { s1, s2 -> Bool in
            let sortDate1 = s1.loginTime.dateValue()
            let sortDate2 = s2.loginTime.dateValue()
            return sortDate2 < sortDate1
        }
        let userData = anotherUsers[indexPath.row]
        // cellのプロパティにデータを与えてそれを元に高さを求めることは難しいかできないみたいだから、高さが可変するtextViewに入れる文字列を計算してcellの高さを決める。
        let attributes: [NSAttributedString.Key: Any] = [.font: cell.userMessageTextView.font as Any]
        let textPadding = cell.userMessageTextView.textContainer.lineFragmentPadding * 2
        // Stringを拡張して文字列の幅と高さを計算する。文字列の実際の幅を計算するためtextViewのpaddingを引いて計算。
        let messageHeight = userData.introduction.textSizeCalc(width: contentWidth - textPadding, attribute: attributes)
        // 他のUIKitとmargin、textViewのpaddingを計算する。
        let fixedHeight = cell.topStackView.bounds.height + cell.userLoginTime.bounds.height + 50
        let height = messageHeight.height + fixedHeight
        return height
    }
}

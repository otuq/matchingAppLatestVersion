//
//  NarrowDownViewController.swift
//  matchingApp
//
//  Created by USER on 2022/02/09.
//  Copyright © 2022 otuq. All rights reserved.
//

import Eureka
import UIKit

class NarrowDownViewController: FormViewController {
    // MARK: Properties
    private let userDefaults = UserDefaults.standard
    private let age = { () -> [String] in
        var array = [Int](18...100).map { String($0) + "歳" }
        array.insert("未設定", at: 0)
        return array
    }
    private let locations = [
        "未設定", "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
    ]
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        formSetting()
    }
    private func settingView() {
        self.navigationItem.title = "絞り込み検索"
        self.navigationItem.leftBarButtonItem = .init(title: "閉じる", style: .plain, target: self, action: #selector(tapActionClose))
        self.navigationItem.rightBarButtonItem = .init(title: "検索", style: .plain, target: self, action: #selector(tapActionSave))
    }
    @objc private func tapActionClose() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc private func tapActionSave() {
        // 絞り込み検索。formのデータからsearchに格納している他ユーザー情報を絞り込む。
        guard let nav = self.navigationController,
              let searchVC = nav.viewControllers[nav.viewControllers.count - 2]as? SearchViewController,
              var narrowDownUsers = searchVC.duplicateAnotherUsers else { return }

        let formValues = form.values()
        let values = User(dic: formValues as [String: Any])
        // Firebaseから取得しているnarrowDownUsersをコピーしてそれを元に絞り込む。
        narrowDownUsers = values.gender != "未設定" ? narrowDownUsers.filter({ $0.gender == values.gender }): narrowDownUsers
        narrowDownUsers = values.age != "未設定" ? narrowDownUsers.filter({ $0.age == values.age }): narrowDownUsers
        narrowDownUsers = values.location != "未設定" ? narrowDownUsers.filter({ $0.location == values.location }): narrowDownUsers
        // 先にユーザーデフォルトを保存しないとsearchVC側でfilterが更新されないので注意
        userDefaults.set(formValues, forKey: "form")

        searchVC.anotherUsers.removeAll()
        searchVC.anotherUsers = narrowDownUsers
        // リロードしないと直前のデータの情報が残っていてレイアウトが崩れるので注意。
        searchVC.searchCollectionView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
    private func formSetting() {
        let formValues = userDefaults.object(forKey: "form")as? [String: Any]
        let values = User(dic: formValues ?? [:])
        self.form +++ Section("section1")
            <<< SegmentedRow<String>("gender") {
                $0.options = ["未設定", "男性", "女性"]
                $0.title = "性別"
                $0.value = formValues != nil ? values.gender : "未設定"
            }
            <<< PickerInputRow<String>("age") {
                $0.options = age()
                $0.title = "年齢"
                $0.value = formValues != nil ? values.age : "未設定"
            }
            <<< PickerInputRow<String>("location") {
                $0.options = locations
                $0.title = "場所"
                $0.value = formValues != nil ? values.location : "未設定"
            }
    }
}

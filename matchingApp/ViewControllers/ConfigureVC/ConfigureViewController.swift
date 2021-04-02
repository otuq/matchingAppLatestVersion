//
//  ConfigureViewController.swift
//  matchingApp
//
//  Created by USER on 2022/1/20.
//  Copyright © 2022 otuq. All rights reserved.
//

import Eureka
import UIKit

protocol ConfigureOutput: AnyObject {
    func profileVCReloadAndDismiss()
}
class ConfigureViewController: FormViewController {
    // MARK: Properties
    private let age = { () -> [String] in
        var array = [Int](18...100).map { String($0) + "歳" }
        array.insert("未設定", at: 0)
        return array
    }
    private let locations = [
        "未設定", "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
    ]
    private var presenter: ConfigurePresenter!
    var currentUser: User? // Profileの編集ボタンを押すと渡される

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        settingView()
        formSetting()
    }
    private func initialize() {
        presenter = ConfigurePresenter(with: self)
    }
    private func settingView() {
        navigationItem.title = "設定"
        navigationItem.leftBarButtonItem = .init(title: "閉じる", style: .plain, target: self, action: #selector(tapActionClose))
        navigationItem.rightBarButtonItem = .init(title: "保存", style: .plain, target: self, action: #selector(tapActionUpdateFirestore))
    }

    @objc private func tapActionClose() {
        self.dismiss(animated: true, completion: nil)
    }
    private func formSetting() {
        self.form +++ Section()
            <<< TextRow("name") {
                $0.title = "ユーザー名"
                $0.value = self.currentUser?.name
            }
            <<< SegmentedRow<String>("gender") {
                $0.options = ["未設定", "男性", "女性"]
                $0.title = "性別"
                $0.value = self.currentUser?.gender
            }
            <<< PickerInputRow<String>("age") {
                $0.options = age()
                $0.title = "年齢"
                $0.value = self.currentUser?.age
            }
            <<< PickerInputRow<String>("location") {
                $0.options = locations
                $0.title = "場所"
                $0.value = self.currentUser?.location
            }
            +++ Section("自己紹介")
            <<< TextAreaRow("introduction") {
                $0.title = "自己紹介"
                $0.value = self.currentUser?.introduction
                $0.textAreaHeight = .fixed(cellHeight: 300)
            }
    }
    @objc private func tapActionUpdateFirestore() {
        // ユーザーが変更したformのデータをFirebaseにアップロード
        let updateData = form.values() as [AnyHashable: Any]
        presenter.updateConfigure(updateData: updateData)
    }
}
// MARK: - Presenter
extension ConfigureViewController: ConfigureOutput {
    func profileVCReloadAndDismiss() {
        let tab = self.presentingViewController as! UITabBarController
        let nav = tab.selectedViewController as! UINavigationController
        let profileVC = nav.viewControllers[nav.viewControllers.count - 1]as? ProfileViewController
        profileVC?.viewDidLoad()
        NotificationCenter.default.post(name: .profileUpdate, object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

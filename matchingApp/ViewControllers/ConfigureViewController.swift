//
//  ConfigureViewController.swift
//  matchingApp
//
//  Created by USER on 2020/11/20.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import Eureka
import FirebaseFirestore
import FirebaseAuth

class ConfigureViewController: FormViewController {
    
    var user: User?
    
    private let age = { () -> [String] in
        var array = [Int](18...100).map{String($0) + "歳"}
        array.insert("未設定", at: 0)
        return array
    }
    private let locations = ["未設定","北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        formSetting()
    }
    private func settingView(){
        self.navigationItem.title = "設定"
        self.navigationItem.leftBarButtonItem = .init(title: "閉じる", style: .plain, target: self, action: #selector(tapActionClose))
        self.navigationItem.rightBarButtonItem = .init(title: "保存", style: .plain, target: self, action: #selector(tapActionSave))
    }
    @objc private func tapActionClose(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func tapActionSave(){
        //ユーザーが変更したformのデータをFirebaseにアップロード
        let updateData = form.values()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("user").document(uid).updateData(updateData as [AnyHashable : Any]) { (error) in
            if let err = error{
                print("ユーザー情報のアップデートに失敗しました。",err)
                return
            }
            print("ユーザー情報のアップデートに成功しました。")
            let tab = self.presentingViewController as! UITabBarController
            let nav = tab.selectedViewController as! UINavigationController
            let profileVC = nav.viewControllers[nav.viewControllers.count-1]as? ProfileViewController
            profileVC?.viewDidLoad()
            NotificationCenter.default.post(name: .profileUpdate, object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    private func formSetting(){
        self.form +++ Section("section1")
            <<< TextRow("name"){
                $0.title = "ユーザー名"
                $0.value = self.user?.name
            }
            <<< SegmentedRow<String>("gender"){
                $0.options = ["未設定","男性","女性"]
                $0.title = "性別"
                $0.value = self.user?.gender
            }
            <<< PickerInputRow<String>("age"){
                $0.options = age()
                $0.title = "年齢"
                $0.value = self.user?.age
            }
            <<< PickerInputRow<String>("location"){
                $0.options = locations
                $0.title = "場所"
                $0.value = self.user?.location
        }
    }
}

//
//  SignUpViewController.swift
//  matchingApp
//
//  Created by USER on 2022/1/20.
//  Copyright © 2022 otuq. All rights reserved.
//

import UIKit

// tag番号
enum PickerTag: Int {
    case age, locaton
}
enum UserInfo: String {
    case name, gender, age, location, image
}
protocol SignUpOutput: AnyObject {
    var userInfoArray: [UserInfo: Any?] { get }
    func signUpReload()
}
class SignUpViewController: UIViewController {
    // MARK: properties
    private let dynamicColor = UIColor.dynamicColor(light: .black, dark: .white)
    private let age = { () -> [String] in
        var array = [Int](18...100).map { String($0) + "歳" }
        array.insert("未設定", at: 0)
        return array
    }
    private let locations = [
        "未設定", "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
    ]
    private var gender: String?
    private var presenter: SignUpPresenter!
    private let agePickerView = UIPickerView()
    private let locationPickerView = UIPickerView()

    // MARK: - Outlets
    @IBOutlet var userProfileImageView: UIButton!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userGenderSegment: UISegmentedControl!
    @IBOutlet var userAgeTextField: UITextField!
    @IBOutlet var userLocationTextField: UITextField!
    @IBOutlet var registerButton: UIButton!

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        settingView()
        settingProperty()
    }
    private func initialize() {
        presenter = SignUpPresenter(with: self)
        gender = userGenderSegment.titleForSegment(at: 0)
    }
    private func settingProperty() {
        userAgeTextField.text = "未設定"
        userLocationTextField.text = "未設定"
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width / 2
        registerButton.layer.cornerRadius = 10
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = dynamicColor.cgColor
        registerButton.isEnabled = false
        registerButton.layer.opacity = 0.5
    }
    private func settingView() {
        userNameTextField.delegate = self
        userLocationTextField.delegate = self
        userProfileImageView.addTarget(self, action: #selector(tapActionImagePickerView), for: .touchUpInside)
        userGenderSegment.addTarget(self, action: #selector(segmentChange), for: UIControl.Event.valueChanged)
        registerButton.addTarget(self, action: #selector(tapActionRegister), for: .touchUpInside)
        navigationItem.title = "ユーザー登録"
        createPickerView(userAgeTextField, agePickerView, tag: .age) // 年齢入力
        createPickerView(userLocationTextField, locationPickerView, tag: .locaton) // 場所入力
    }
    @objc private func segmentChange(segment: UISegmentedControl) {
        let segmentIndex = segment.selectedSegmentIndex
        gender = userGenderSegment.titleForSegment(at: segmentIndex)
    }
    @objc private func tapActionRegister() {
        presenter.saveFirestore()
    }
}
// MARK: - presenter
extension SignUpViewController: SignUpOutput {
    var userInfoArray: [UserInfo: Any?] {
        [.name: userNameTextField.text,
         .gender: gender,
         .age: userAgeTextField.text,
         .location: userLocationTextField.text,
         .image: userProfileImageView.imageView?.image
        ]
    }
    func signUpReload() {
        let tab = self.presentingViewController as! UITabBarController
        let nav = tab.selectedViewController as! UINavigationController
        let searchVC = nav.viewControllers[nav.viewControllers.count - 1]as? SearchViewController
        searchVC?.viewDidLoad()
        // Profile、ChatListに通知
        NotificationCenter.default.post(name: .signUpLoad, object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let userName = userNameTextField.text?.isEmpty ?? false
        if userName {
            registerButton.isEnabled = false
            registerButton.layer.opacity = 0.5
        } else {
            registerButton.isEnabled = true
            registerButton.layer.opacity = 1
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userNameTextField.endEditing(true)
        userLocationTextField.endEditing(true)
    }
}
// MARK: - UIPickerViewDelegate,UIPickerViewDataSource
extension SignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func createPickerView(_ textField: UITextField, _ pickerView: UIPickerView, tag: PickerTag) {
        // キーボードにピッカービューをinputする。
        pickerView.delegate = self
        // tag番号
        pickerView.tag = tag.rawValue
        // ツールバーをピッカービューにinputする
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        // ツールバーにボタンを設置する。
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(tapActionDoneButton))
        toolbar.setItems([doneButton], animated: true)
        // textFieldのキーボードをpickerViewにする
        textField.inputView = pickerView
        // toolbarをキーボードの上に設置する。
        textField.inputAccessoryView = toolbar
    }
    // テキスト入力の終了
    @objc private func tapActionDoneButton() {
        userAgeTextField.endEditing(true)
        userLocationTextField.endEditing(true)
    }
    // 列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 行数、要素の全数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let pickerTag = PickerTag(rawValue: pickerView.tag) {
            switch pickerTag {
            case .age:
                return age().count
            case .locaton:
                return locations.count
            }
        }
        return 0
    }
    // 表示する配列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let picerTag = PickerTag(rawValue: pickerView.tag) {
            switch picerTag {
            case .age:
                return age()[row]
            case .locaton:
                return locations[row]
            }
        }
        return ""
    }
    // rowが選択された時の処理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let pickerTag = PickerTag(rawValue: pickerView.tag) {
            switch pickerTag {
            case .age:
                userAgeTextField.text = age()[row]
            case .locaton:
                userLocationTextField.text = locations[row]
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // ImagePickerViewを呼び出す
    @objc private func tapActionImagePickerView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    // 写真を選択した後の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 大きさを変えたり編集がされているイメージを取得する
        if let editImage = info[.editedImage]as? UIImage {
            userProfileImageView.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } // 何も編集されていない状態のイメージを取得する
        else if let originalImage = info[.originalImage]as? UIImage {
            userProfileImageView.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        userProfileImageView.imageView?.contentMode = .scaleAspectFill
        userProfileImageView.clipsToBounds = true
        userProfileImageView.contentHorizontalAlignment = .fill
        userProfileImageView.contentVerticalAlignment = .fill
        self.dismiss(animated: true, completion: nil)
    }
}

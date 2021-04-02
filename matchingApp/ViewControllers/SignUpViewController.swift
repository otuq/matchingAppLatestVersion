//
//  StartUpViewController.swift
//  matchingApp
//
//  Created by USER on 2020/11/20.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class SignUpViewController: UIViewController {
    //tag番号
    enum PickerTag: Int{
        case age,locaton
    }
    //MARK: properties
    private var genderValue: String?
    
    private let age = { () -> [String] in
        var array = [Int](18...100).map{String($0) + "歳"}
        array.insert("未設定", at: 0)
        return array
    }
    
    private let locations = [
        "未設定","北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"
    ]
    
    //MARK: -Outlets
    @IBOutlet weak var userProfileImageView: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userGenderSegment: UISegmentedControl!
    @IBOutlet weak var userAgeTextField: UITextField!
    @IBOutlet weak var userLocationTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    //MARK: -views
    private let agePickerView = UIPickerView()
    private let locationPickerView = UIPickerView()
    
    //MARK: -LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        settingProperty()
    }
    
    private func settingProperty(){
        genderValue = userGenderSegment.titleForSegment(at: 0)
        userAgeTextField.text = "未設定"
        userLocationTextField.text = "未設定"
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width/2
        registerButton.layer.cornerRadius = 10
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.darkGray.cgColor
        registerButton.isEnabled = false
        registerButton.layer.opacity = 0.5
    }
    
    private func settingView(){
        userNameTextField.delegate = self
        userLocationTextField.delegate = self
        userProfileImageView.addTarget(self, action: #selector(tapActionImagePickerView), for: .touchUpInside)
        userGenderSegment.addTarget(self, action: #selector(segmentChange), for: UIControl.Event.valueChanged)
        registerButton.addTarget(self, action: #selector(tapActionRegister), for: .touchUpInside)
        
        createPickerView(userAgeTextField,agePickerView,tag: .age) //年齢入力
        createPickerView(userLocationTextField,locationPickerView,tag: .locaton) //場所入力
        
    }
}

//MARK: -Various function
extension SignUpViewController{
    func logoutJudgment(){

        let tab = self.presentingViewController as! TabbarViewController
        let nav = tab.selectedViewController as! UINavigationController
        let searchVC = nav.viewControllers[nav.viewControllers.count-1]as? SearchViewController
        searchVC?.viewDidLoad()
        //Profile、ChatListに通知
        NotificationCenter.default.post(name: .signUpLoad, object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: -Autentication
extension SignUpViewController{
    
    private func authenticationFirestore(url: String){
        //user情報
        guard let userName = self.userNameTextField.text else { return }
        guard let gender = self.genderValue else { return }
        guard let age = self.userAgeTextField.text else { return }
        guard let location = self.userLocationTextField.text else { return }
        
        Auth.signInRegister(
            userName: userName,
            gender: gender,
            age: age,
            location: location,
            imageUrl: url
        ) { (success) in
            if success{
                print("登録保存の完了")
                self.logoutJudgment()
            }
        }
    }
}

//MARK: -UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let userName = userNameTextField.text?.isEmpty ?? false
        if userName{
            registerButton.isEnabled = false
            registerButton.layer.opacity = 0.5
        }else{
            registerButton.isEnabled = true
            registerButton.layer.opacity = 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userNameTextField.endEditing(true)
        userLocationTextField.endEditing(true)
    }
}

//MARK: -UIPickerViewDelegate,UIPickerViewDataSource
extension SignUpViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    
    private func createPickerView(_ textField: UITextField,_ pickerView: UIPickerView, tag: PickerTag){
        //キーボードにピッカービューをinputする。
        pickerView.delegate = self
        //tag番号
        pickerView.tag = tag.rawValue
        //ツールバーをピッカービューにinputする
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        //ツールバーにボタンを設置する。
        let doneButton = UIBarButtonItem.init(title: "完了", style: .done, target: self, action: #selector(tapActionDoneButton))
        toolbar.setItems([doneButton], animated: true)
        //textFieldのキーボードをpickerViewにする
        textField.inputView = pickerView
        //toolbarをキーボードの上に設置する。
        textField.inputAccessoryView = toolbar
    }
    //テキスト入力の終了
    @objc private func tapActionDoneButton(){
        userAgeTextField.endEditing(true)
        userLocationTextField.endEditing(true)
    }
    //列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //行数、要素の全数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let pickerTag = PickerTag.init(rawValue: pickerView.tag){
            switch pickerTag {
            case .age:
                return age().count
            case .locaton:
                return locations.count
            }
        }
        return 0
    }
    //表示する配列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let picerTag = PickerTag.init(rawValue: pickerView.tag){
            switch picerTag {
            case .age:
                return age()[row]
            case .locaton:
                return locations[row]
            }
        }
        return ""
    }
    //rowが選択された時の処理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let pickerTag = PickerTag.init(rawValue: pickerView.tag){
            switch pickerTag {
            case .age:
                userAgeTextField.text = age()[row]
            case .locaton:
                userLocationTextField.text   = locations[row]
            }
        }
    }
}

//MARK: -UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension SignUpViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    //ImagePickerViewを呼び出す
    @objc private func tapActionImagePickerView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    //写真を選択した後の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //大きさを変えたり編集がされているイメージを取得する
        if let editImage = info[.editedImage]as? UIImage{
            userProfileImageView.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //何も編集されていない状態のイメージを取得する
        if let originalImage = info[.originalImage]as? UIImage{
            userProfileImageView.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        userProfileImageView.imageView?.contentMode = .scaleAspectFill
        userProfileImageView.clipsToBounds = true
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: -Register
extension SignUpViewController{
    
    @objc private func segmentChange(segment: UISegmentedControl){
        let segmentIndex = segment.selectedSegmentIndex
        genderValue = userGenderSegment.titleForSegment(at: segmentIndex)
    }
    
    @objc private func tapActionRegister(){
        guard let image = userProfileImageView.imageView?.image ?? UIImage(named: "tsuno") else { return }
        guard let jpgData = image.jpegData(compressionQuality: 0.3) else { return }
        let userDefault = UserDefaults.standard
        let uuidString = NSUUID().uuidString
        //Profileのアップデートで使う
        userDefault.set(uuidString, forKey: "uuid")
        
        Storage.addImageStorage(uuidString: uuidString, jpgData: jpgData) { (url) in
            self.authenticationFirestore(url: url)
        }
    }
}

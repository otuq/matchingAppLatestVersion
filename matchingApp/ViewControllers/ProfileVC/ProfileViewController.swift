//
//  ProfileViewController.swift
//  matchingApp
//
//  Created by USER on 2022/1/19.
//  Copyright © 2022 otuq. All rights reserved.
//

import Nuke
import UIKit

protocol ProfileOutput: AnyObject {
    func fetchUserInfo(user: User)
}
class ProfileViewController: UIViewController {
    // MARK: Properties
    private var currentUser: User?
    private var presenter: ProfilePresenter!

    // MARK: - Outlets
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userInfoLabel: UILabel!
    @IBOutlet var introductionTextView: UITextView!
    @IBOutlet var userProfileEditButton: UIButton!

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        settingView()
        presenter.fetchUserInfo()
        // SignUpVCから通知
        NotificationCenter.default.addObserver(self, selector: #selector(signUpLoad), name: .signUpLoad, object: nil)
    }
    private func initialize() {
        presenter = ProfilePresenter(with: self)
    }
    private func settingView() {
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        userImageView.contentMode = .scaleAspectFill

        introductionTextView.layer.cornerRadius = 10
        introductionTextView.layer.borderWidth = 1
        introductionTextView.layer.borderColor = UIColor.label.cgColor

        userProfileEditButton.layer.cornerRadius = userProfileEditButton.bounds.height / 3
        userProfileEditButton.layer.borderWidth = 1
        userProfileEditButton.layer.borderColor = UIColor.label.cgColor

        userProfileEditButton.addTarget(self, action: #selector(tapActionProfileEdit), for: .touchUpInside)

        navigationItem.title = "プロフィール"
    }
    private func userInfoUISetting(user: User) {
        self.userNameLabel.text = user.name
        self.userInfoLabel.text = "\(user.location)/\(user.gender)/\(user.age)"
        self.introductionTextView.text = user.introduction
        if let urlString = URL(string: user.imageUrl) {
            Nuke.loadImage(with: urlString, into: userImageView)
        }
    }
    // MARK: Notification
    @objc private func signUpLoad() {
        settingView()
        presenter.fetchUserInfo()
    }
    // プロフィールの編集ボタンを押したら下からにゅっとメニューを表示
    @objc private func tapActionProfileEdit() {
        let alertAction = UIAlertController(title: "プロフィールの編集", message: "編集する項目を選択してください", preferredStyle: .actionSheet)
        let photoEditAction = UIAlertAction(title: "写真の変更", style: .default) { _ in
            self.tapActionPhotoEdit(edit: "photo")
        }
        let profileEditAction = UIAlertAction(title: "プロフィールの編集", style: .default) { _ in
            self.tapActionPhotoEdit(edit: "profile")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertAction.addAction(photoEditAction)
        alertAction.addAction(profileEditAction)
        alertAction.addAction(cancelAction)

        self.present(alertAction, animated: true, completion: nil)
    }

    func tapActionPhotoEdit(edit: String) {
        if edit == "photo"{
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        if edit == "profile"{
            let storyborad = UIStoryboard(name: "Configure", bundle: nil)
            let viewController = storyborad.instantiateViewController(withIdentifier: "ConfigureViewController")as! ConfigureViewController
            viewController.currentUser = self.currentUser
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .overFullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}
// MARK: - Presenter
extension ProfileViewController: ProfileOutput {
    func fetchUserInfo(user: User) {
        self.currentUser = user
        self.userInfoUISetting(user: user)
    }
}

// MARK: - PickerControllerDelegate,UINavigationControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editImage = info[.editedImage]as? UIImage {
            userImageView.image = editImage.withRenderingMode(.alwaysOriginal)
            print("editimageです")
        } else if let originalImage = info[.originalImage]as? UIImage {
            userImageView.image = originalImage.withRenderingMode(.alwaysOriginal)
            print("originalimageです")
        }
        presenter.updateStorage(image: userImageView.image)
        self.dismiss(animated: true, completion: nil)
    }
}

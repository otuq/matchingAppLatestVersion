//
//  ProfileViewController.swift
//  matchingApp
//
//  Created by USER on 2020/11/19.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import Firebase
import Nuke


class ProfileViewController: UIViewController {
    
    private var user: User?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var userProfileEditButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView()
        fetchUserInfo()
    }
    
    private func settingView(){
        userImageView.layer.cornerRadius = userImageView.bounds.width/2
        userImageView.contentMode = .scaleAspectFill
        userProfileEditButton.layer.cornerRadius = userProfileEditButton.bounds.height/3
        userProfileEditButton.layer.borderWidth = 1
        userProfileEditButton.addTarget(self, action: #selector(tapActionProfileEdit), for: .touchUpInside)
    }
    
    @objc private func tapActionProfileEdit(){
        let storyborad = UIStoryboard.init(name: "ModalWindow", bundle: nil)
        let viewController = storyborad.instantiateViewController(withIdentifier: "ModalWindowViewController")as! ModalWindowViewController
        //遷移先をnavigationcontrollerにセットしてからdelegateにselfを入れてたのでうまくいかなかった。nav.delegate = self
        viewController.delegate = self
        let nav = UINavigationController.init(rootViewController: viewController)
        nav.modalPresentationStyle = .overFullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func fetchUserInfo(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("user").document(uid).getDocument { (snapshot, error) in
            if let err = error{
                print("user情報の取得に失敗しました。",err)
                return
            }
            print("user情報の取得に成功しました。")
            guard let dic = snapshot?.data() else { return }
            let user = User(dic: dic)
            self.user = user
            self.userInfoUISetting(user: user)
        }
    }
    private func userInfoUISetting(user: User){
        self.userNameLabel.text = user.name
        self.userInfoLabel.text = "\(user.location)/\(user.gender)/\(user.age)"
        if let urlString = URL(string: user.imageUrl){
            Nuke.loadImage(with: urlString, into: userImageView)
        }
    }
}
//MARK: -PhotoEditDelegate
extension ProfileViewController: PhotoEditDelegate{
    func tapActionPhotoEdit(edit: String) {
        
        if edit == "photo"{
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        if edit == "profile"{
            let storyborad = UIStoryboard.init(name: "Configure", bundle: nil)
            let viewController = storyborad.instantiateViewController(withIdentifier: "ConfigureViewController")as! ConfigureViewController
            viewController.user = self.user
            let nav = UINavigationController.init(rootViewController: viewController)
            self.present(nav, animated: true, completion: nil)
        }
    }
}
//MARK: -PickerControllerDelegate,UINavigationControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage]as? UIImage{
            userImageView.image = editImage.withRenderingMode(.alwaysOriginal)
            print("editimageです")
        }else if let originalImage = info[.originalImage]as? UIImage{
            userImageView.image = originalImage.withRenderingMode(.alwaysOriginal)
            print("originalimageです")
        }
        storageUpdate()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func storageUpdate(){
        let userDefault = UserDefaults.standard
        guard let uuid = userDefault.string(forKey: "uuid") else { return }
        guard let image = userImageView.image else { return }
        guard let jpgData = image.jpegData(compressionQuality: 0.3) else { return }
        let storageRef = Storage.storage().reference().child("prifile_image").child(uuid)
        storageRef.putData(jpgData, metadata: nil) { (updateData, error) in
            if let err = error{
                print("storageへのアップデートに失敗しました。",err)
                return
            }
            print("storageへのアップデートに成功しました。")
            storageRef.downloadURL { (url, error) in
                if let err = error{
                    print("ダウンロードurlの取得に失敗しました。",err)
                    return
                }
                print("ダウンロードurlの取得に成功しました。")
                guard let urlString = url?.absoluteString else { return }
                self.updateImageUrlFirestore(url: urlString)
            }
        }
    }
    
    private func updateImageUrlFirestore(url: String){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let updateData = ["imageUrl": url]
        Firestore.firestore().collection("user").document(uid).updateData(updateData) { (error) in
            if let err = error{
                print("Firestoreへのアップデートに失敗しました。",err)
                return
            }
            print("Firestoreへのアップデートに成功しました。")
            
        }
    }
}

//
//  ContactUserViewController.swift
//  matchingApp
//
//  Created by USER on 2022/2/14.
//  Copyright © 2022 otuq. All rights reserved.
//
import Nuke
import UIKit

protocol ContactUserOutput: AnyObject {
    var anotherUserPresent: User? { get }
    func transitionChatMessageVC(_ viewController: UIViewController)
}
class ContactUserViewController: UIViewController {
    // MARK: Properties
    private var presenter: ContactUserPresenter!
    var anotherUser: User? // searchVCのセルがdidselectされたらuserデータが渡る

    // MARK: Outlets
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var userInfoLabel: UILabel!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var messageCancelButton: UIButton!
    @IBOutlet var introductionTextView: UITextView!

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        settingView()
        userInfoUISetting()
    }
    private func initialize() {
        presenter = ContactUserPresenter(with: self)
    }
    private func settingView() {
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        userImageView.contentMode = .scaleAspectFill

        messageButton.layer.cornerRadius = 10
        messageButton.layer.borderWidth = 1
        messageButton.layer.borderColor = UIColor.label.cgColor

        messageCancelButton.layer.cornerRadius = 10
        messageCancelButton.layer.borderWidth = 1
        messageCancelButton.layer.borderColor = UIColor.label.cgColor

        introductionTextView.layer.cornerRadius = 10
        introductionTextView.layer.borderWidth = 1
        introductionTextView.layer.borderColor = UIColor.label.cgColor

        messageButton.addTarget(self, action: #selector(tapActionMessageButton), for: .touchUpInside)
        messageCancelButton.addTarget(self, action: #selector(tapActionMessageCancelButton), for: .touchUpInside)
    }
    @objc private func tapActionMessageButton() {
        presenter.tapActionMessageButton()
    }
    @objc private func tapActionMessageCancelButton() {
        navigationController?.popViewController(animated: true)
    }

    private func userInfoUISetting() {
        guard let anotherUser = anotherUser else { return }
        usernameLabel.text = anotherUser.name
        userInfoLabel.text = "\(anotherUser.location)/\(anotherUser.gender)/\(anotherUser.age)"
        introductionTextView.text = anotherUser.introduction
        if let urlString = URL(string: anotherUser.imageUrl) {
            Nuke.loadImage(with: urlString, into: userImageView)
        }
    }
}
// MARK: - Presenter
extension ContactUserViewController: ContactUserOutput {
    var anotherUserPresent: User? { anotherUser }
    func transitionChatMessageVC(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}

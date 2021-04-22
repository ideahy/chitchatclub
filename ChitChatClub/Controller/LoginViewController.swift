//
//  LoginViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/21.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotification()
        setupViews()
    }
    
    private func setupNotification() {
        //キーボードが出てくる時の通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //notification = キーボードの情報を通知
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if !passwordTextField.isFirstResponder {
            return
        }
        
        if self.view.frame.origin.y == 0 {
            if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let top = keyboardFrame.height - safeAreaBottom
                //画面外に行きすぎるので100ずらす
                self.view.frame.origin.y -= top - 200
            }
        }
    }

    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    private func setupViews() {
        loginButton.layer.cornerRadius = 8
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //初期はボタン押せない
        
        loginButton.isEnabled = false
        loginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)

    }

    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func tappedLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        //ログイン時のindicatorを表示する
        HUD.show(.progress)

        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログインに失敗しました。\(err)")
                HUD.hide()
                return
            }
            HUD.hide()
            print("ログインに成功しました。")
                        let nav = self.presentingViewController as! UINavigationController
            let chatListViewController = nav.viewControllers[nav.viewControllers.count-1] as? ChatListViewController
            chatListViewController?.fetchChatroomsInfoFromFirestore()

            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}


extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //textField全てに適用
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        //一つでも空があるとボタンを押せなくする
        if emailIsEmpty || passwordIsEmpty {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
    }
    
    //リターンキーで閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

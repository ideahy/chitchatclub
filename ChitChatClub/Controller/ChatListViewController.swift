//
//  ChatListViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/15.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ChatListViewController: UIViewController {

    //セル指定用(SB上にも要記入)
    private let cellId = "cellId"
    //フェッチしたユーザー情報を格納する
    private var users = [User]()
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        //naviBarの色を変更
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //会員登録済みである場合も表示されるため表示の切り分け
        if Auth.auth().currentUser?.uid == nil{
            //チャットユーザーリストが起動した際に画面遷移
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
            //サインアップ用のモーダルをフル画面で表示
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true, completion: nil)
        }
    }
    
    //成功しましたログの前にユーザー情報が出てきているので変更
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ユーザー情報が正しく受け取れるかを確認するメソッド
        fetchUserInfoFromFirestore()
        //受け取った情報を使いやすいようにModelに格納する
    }
    
    //ユーザー情報が正しく受け取れるかを確認するメソッド
    private func fetchUserInfoFromFirestore() {
        //Firestoreから保存されている値をフェッチ
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err{
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            print("user情報の取得に成功しました。")
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                //フェッチしたdata(dic)をuserに変換
                let user = User.init(dic: dic)
                self.users.append(user)
                //念の為確認(ユーザーネームだけ表示する)
                self.users.forEach { (user) in
                    print("user.username: ", user.username)
                }
            })
        }
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource 処理用
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを指定して紐づける
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("タップしたよ")
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController")
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}


class ChatListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //角丸
        userImageView.layer.cornerRadius = 35
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

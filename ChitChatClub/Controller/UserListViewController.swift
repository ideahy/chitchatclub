//
//  UserListViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/20.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Nuke

class UserListViewController: UIViewController {

    private let cellId = "cellId"
    private var users = [User]()
    //どのユーザーとの新規チャットを開始したかわかる仕様にしたい
    private var selectedUser: User?

    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        startChatButton.addTarget(self, action: #selector(tappedStartChatButton), for: .touchUpInside)

        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        fetchUserInfoFromFirestore()
    }

    @objc func tappedStartChatButton() {
        print("tappedStartChatButton")
        //チャット中ユーザーの情報、最新テキスト、時間
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid, partnerUid]

        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt": Timestamp()
        ] as [String : Any]

        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err {
                print("ChatRoom情報の保存に失敗しました。\(err)")
                return
            }

            self.dismiss(animated: true, completion: nil)
            print("ChatRoom情報の保存に成功しました。")

        }

    }

    private func fetchUserInfoFromFirestore() {
        //Firestoreから保存されている値をフェッチ
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }

            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                //フェッチしたdata(dic)をuserに変換
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID

                guard let uid = Auth.auth().currentUser?.uid else { return }

                if uid == snapshot.documentID {
                    return
                }

                self.users.append(user)
                self.userListTableView.reloadData()
            })
        }
    }


}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]

        return cell
    }

    //ユーザーのセルを選択時に情報を取得する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        let user = users[indexPath.row]
        self.selectedUser = user
        //取得したユーザー情報をFirestoreに保存する
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}


//Firestoreから取得した画像URLを変換して表示するライブラリを利用する
class UserListTableViewCell: UITableViewCell {

    var user: User? {
        didSet {
            usernameLabel.text = user?.username

            //Nukeを使うにはURLが必要
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 32.5

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

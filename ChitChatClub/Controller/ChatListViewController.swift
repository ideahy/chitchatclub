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
import FirebaseStorage
import Nuke

class ChatListViewController: UIViewController {
    
    //セル指定用(SB上にも要記入)
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    
    //ユーザー情報がセットされた時点でナビバーに表示したい
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        confirmLoggedInUser()
        fetchLoginUserInfo()
        fetchChatroomsInfoFromFirestore()
        
    }
    
    private func fetchChatroomsInfoFromFirestore() {
        Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshots, err) in
                if let err = err {
                    print("chatRooms情報の取得に失敗しました。\(err)")
                    return
                }
                //リアルタイム更新
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    //Firestoreに新規追加のみ取得
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified, .removed:
                        print("nothing to do")
                    }
                })
            }
    }
    
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        //取得データをモデルに格納
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        //partnerの情報も追加
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //自分がメンバーに含まれているかによってチャットルームの表示を変更する
        let isContain = chatroom.members.contains(uid)
        if !isContain { return }
        
        chatroom.members.forEach { (memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument { (snapshot, err) in
                    if let err = err {
                        print("パートナーユーザー情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    guard let dic = snapshot?.data() else { return }
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    //相手側のユーザー情報を追加
                    chatroom.partnerUser = user
                    self.chatrooms.append(chatroom)
                    print("self.chatrooms.count: ", self.chatrooms.count)
                    self.chatListTableView.reloadData()
                }
            }
        }
    }
    
    private func setupViews() {
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        //naviBarの色を変更
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //ナビゲーションバー右側にボタンを作成
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    private func confirmLoggedInUser() {
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
    
    //ナビゲーションバー右側にボタンを作成
    @objc private func tappedNavRightBarButton() {
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewController = storyboard.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListViewController)
        self.present(nav, animated: true, completion: nil)
    }
    
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err{
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
        }
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource 処理用
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを指定して紐づける
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        
        cell.chatroom = chatrooms[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("タップしたよ")
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}


class ChatListTableViewCell: UITableViewCell {
    
    //ユーザー情報をここで渡す
    //    var user: User? {
    //        didSet{
    //            if let user = user{
    //                partnerLabel.text = user.username
    //                //userImageView.image = user?.profileImageUrl
    //                dateLabel.text = dateFormatterForDateLabel(date: user.createdAt.dateValue())
    //                latestMessageLabel.text = user.email
    //            }
    //        }
    //    }
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom{
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dateFormatterForDateLabel(date: chatroom.createdAt.dateValue())
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //角丸
        userImageView.layer.cornerRadius = 30
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //作成時間表記のフォーマット
    private func dateFormatterForDateLabel(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

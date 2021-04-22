//
//  ChatRoomViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ChatRoomViewController: UIViewController {

    var user: User?
    var chatroom: ChatRoom?


    private let cellId = "cellId"
    //動作用のメッセージ受け渡し配列
    private var messages = [Message]()
    private let accessaryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }

    //入力用Viewをインスタンス化
    //selfが呼び出せないのでlazyを追加
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessaryHeight)
        //Delegateを使って入力テキストを大元のコントローラに渡す(ChatInputAccessoryView続き)
        view.delegate = self
        return view
    }()

    @IBOutlet weak var chatRoomTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotification()
        setupChatRoomTableView()
        fetchMessages()
    }
    
    private func setupNotification() {
        //キーボードが出てくる時の通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupChatRoomTableView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        //別ファイルで記述した場合はregisterが必要
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        //セーフエリア以外に画面枠を調整したい場合
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= accessaryHeight { return }
            
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - chatRoomTableView.contentOffset.y)
            //最下部以外の時はズレるので微調整
            if chatRoomTableView.contentOffset.y != -60 { moveY += 60 }
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }

    @objc func keyboardWillHide() {
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
    }

    //入力用Viewインスタンス → 元々あるinputAccessoryViewプロパティをオーバーライドする
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }

    //もう一つ、元々あるプロパティをオーバーライドする
    override var canBecomeFirstResponder: Bool {
        return true
    }

    //すでに保存されているメッセージをルーム内に表示する
    private func fetchMessages() {
        //個人チャットルームID
        guard let chatroomDocId = chatroom?.documentId else { return }
        //ドキュメントに変更があった場合に呼び出し
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, err) in

            if let err = err {
                print("追加されたメッセージ情報の取得に失敗しました。\(err)")
                return
            }
            //追加があった場合に呼び出し
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser

                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }

                    self.chatRoomTableView.reloadData()
//                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)

                case .modified, .removed:
                    print("nothing to do")
                }
            })


        }


    }

}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {

    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }

    private func addMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        //"latestMessageId"をこちら側で作成しておくためのメソッド
        let messageId = randomString(length: 20)

        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }



            let latestMessageData = [
                "latestMessageId": messageId
            ]

            //最新メッセージを表示する
            Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                if let err = err {
                    print("最新メッセージの保存に失敗しました。\(err)")
                    return
                }

                print("最新メッセージの保存に成功しました。")

            }
        }
    }

    //"latestMessageId"をこちら側で作成しておくためのメソッド
    func randomString(length: Int) -> String {
            let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(letters.length)

            var randomString = ""
            for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            return randomString
    }

}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //動作用のメッセージ受け渡し配列(セルの数)
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //as! ChatRoomTableViewCell -> アクセス可能
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        //反転の反転
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        //送信した値を表示する
        //cell.messageTextView.text = messages[indexPath.row]
        //メッセージ幅に合わせてViewを可変にする
        cell.message = messages[indexPath.row]
        return cell
    }

}

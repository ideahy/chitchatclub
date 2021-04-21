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
    
    //入力用Viewをインスタンス化
    //selfが呼び出せないのでlazyを追加
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        //Delegateを使って入力テキストを大元のコントローラに渡す(ChatInputAccessoryView続き)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        //別ファイルで記述した場合はregisterが必要
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        //Firestore内に変更があった場合に呼び出し
        fetchMessages()
    }
    
    //入力用Viewインスタンス → 元々あるinputAccessoryViewプロパティをオーバーライドする
    override var inputAccessoryView: UIView?{
        get {
            return chatInputAccessoryView
        }
    }
    
    //もう一つ、元々あるプロパティをオーバーライドする
    override var canBecomeFirstResponder: Bool{
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
                    self.chatRoomTableView.reloadData()
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()

        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document().setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            print("メッセージの保存に成功しました。")
        }
    }
}

extension ChatRoomViewController: UITableViewDelegate,UITableViewDataSource{
    
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
        //送信した値を表示する
        //cell.messageTextView.text = messages[indexPath.row]
        //メッセージ幅に合わせてViewを可変にする
        cell.message = messages[indexPath.row]
        return cell
    }
}

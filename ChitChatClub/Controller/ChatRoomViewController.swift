//
//  ChatRoomViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/16.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    private let cellId = "cellId"
    //動作用のメッセージ受け渡し配列
    private var messages = [String]()
    
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
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    func tappedSendButton(text: String) {
        messages.append(text)
        //送信後には送信ボタンを押せなくする
        chatInputAccessoryView.removeText()
        chatRoomTableView.reloadData()
        print("ChatInputAccessoryViewDelegate text: ", text)
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
        cell.messageText = messages[indexPath.row]
        return cell
    }
}

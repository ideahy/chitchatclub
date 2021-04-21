//
//  ChatInputAccessoryView.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/16.
//

//
//Delegateを使って入力テキストを大元のコントローラに渡す
// -> Protocolを作成する -> weak var delegate
//


import UIKit

//循環参照を防ぐためにclassを追加
protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func tappedSendButton(_ sender: Any) {
        //テキスト内に何もない場合はリターンを返す
        guard let text = chatTextView.text else { return }
        //Delegateを使って入力テキストを大元のコントローラに渡す
        delegate?.tappedSendButton(text: text)
        //ChatRoomViewControllerでdelegateを用いてデータを受け取る
    }
    
    //Delegateを使って入力テキストを大元のコントローラに渡す
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
    }
    
    private func setupViews() {
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        chatTextView.text = ""
        //入力テキストを常に保存してキープ
        chatTextView.delegate = self
    }
    
    //チャット送信後に送信ボタンを押せなくする
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    
    //Xibファイルを紐づけるためのメソッド
    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        //フレームのサイズを決める
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//入力テキストを常に保存してキープ
extension ChatInputAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
}

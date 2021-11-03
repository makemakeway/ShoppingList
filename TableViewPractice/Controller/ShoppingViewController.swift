//
//  ShoppingViewController.swift
//  TableViewPractice
//
//  Created by 박연배 on 2021/10/13.
//

import UIKit
import RealmSwift

class ShoppingViewController: UIViewController {

    
    //MARK: Property
    
    let localRealm = try! Realm()
    
    var tasks: Results<ShoppingItem>!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerContainerView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    //MARK: Method
    
    @IBAction func filterButtonClicked(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let checked = UIAlertAction(title: "완료", style: .default) { _ in
            print("check")
            self.tasks = self.localRealm.objects(ShoppingItem.self).sorted(byKeyPath: "checked", ascending: false)
            self.tableView.reloadData()
        }
        
        let sortedTitle = UIAlertAction(title: "제목", style: .default) { _ in
            print("제목 순서")
            self.tasks = self.localRealm.objects(ShoppingItem.self).sorted(byKeyPath: "text", ascending: true)
            self.tableView.reloadData()
        }
        
        let stared = UIAlertAction(title: "즐겨찾기", style: .default) { _ in
            print("즐겨찾기")
            self.tasks = self.localRealm.objects(ShoppingItem.self).sorted(byKeyPath: "stared", ascending: false)
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        
        
        alert.addAction(checked)
        alert.addAction(sortedTitle)
        alert.addAction(stared)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func addList(_ sender: UIButton) {
        guard let text = textField.text, !text.isEmpty else {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let task = ShoppingItem(checked: false, text: text, stared: false)
        try! localRealm.write {
            localRealm.add(task)
        }
        print(localRealm.configuration.fileURL)
        
        tableView.reloadData()
    }
    
    func headerContainerViewConfig() {
        headerContainerView.layer.cornerRadius = 10
    }
    
    func textFieldConfig() {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
    }
    
    @objc func checkButtonClicked(_ sender: UIButton) {
        print("\(sender.tag)번 버튼 눌림")
        
        try! localRealm.write {
            tasks[sender.tag].checked.toggle()
            tableView.reloadData()
        }
        
        
    }
    
    @objc func starButtonClicked(_ sender: UIButton) {
        print("\(sender.tag)번 버튼 눌림")
        
        try! localRealm.write {
            tasks[sender.tag].stared.toggle()
            tableView.reloadData()
        }
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = localRealm.objects(ShoppingItem.self)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        textField.delegate = self
        textFieldConfig()
        headerContainerViewConfig()
        
        let gesture = UITapGestureRecognizer()
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
}


//MARK: TableView Delegate
extension ShoppingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    //MARK: Cell Config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingTableViewCell", for: indexPath) as? ShoppingTableViewCell else {
            
            print("기본 셀 반환")
            return UITableViewCell()
        }
        
        let data = tasks[indexPath.row]
        
        //Cell CheckButton Config
        cell.checkMark.tag = indexPath.row
        
        if data.checked {
            cell.checkMark.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            cell.checkMark.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        }
        
        cell.checkMark.addTarget(self, action: #selector(checkButtonClicked(_:)), for: .touchUpInside)
        
        
        //Cell Label Config
        cell.shoppingLabel.text = data.text
        cell.shoppingLabel.numberOfLines = 0
        
        
        //Cell StarButton Config
        cell.starMark.tag = indexPath.row
        
        if data.stared {
            cell.starMark.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            cell.starMark.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        cell.starMark.addTarget(self, action: #selector(starButtonClicked(_:)), for: .touchUpInside)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! localRealm.write {
                localRealm.delete( tasks[indexPath.row] )
                tableView.reloadData()
            }
        }
    }
}

//MARK: TextField Delegate
extension ShoppingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !textField.text!.isEmpty {
            try! localRealm.write {
                localRealm.add(ShoppingItem(checked: false, text: textField.text!, stared: false))
                tableView.reloadData()
            }
        } else {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
            
        }
        
        return true
    }
}

//MARK: GestureRecognizer Delegate

extension ShoppingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != textField {
            view.endEditing(true)
        }
        
        return true
    }
}

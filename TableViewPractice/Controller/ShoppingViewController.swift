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
    
    var shoppingList: [ShoppingModel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    //MARK: Method
    
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
        
        tableView.reloadData()
    }
    
    func fetchList() {
        if let data = UserDefaults.standard.object(forKey: "shoppingList") as? Data {
            self.shoppingList = try! PropertyListDecoder().decode([ShoppingModel].self, from: data)
        }
        
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
        shoppingList[sender.tag].checked.toggle()
        
        
    }
    
    @objc func starButtonClicked(_ sender: UIButton) {
        print("\(sender.tag)번 버튼 눌림")
        shoppingList[sender.tag].stared.toggle()
        
        
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
        fetchList()
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
        if data.checked {
            cell.checkMark?.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            cell.checkMark?.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        }
        cell.checkMark?.tag = indexPath.row
        cell.checkMark?.addTarget(self, action: #selector(checkButtonClicked(_:)), for: .touchUpInside)
        
        
        //Cell Label Config
        cell.shoppingLabel?.text = data.text
        cell.shoppingLabel?.numberOfLines = 0
        
        
        //Cell StarButton Config
        if data.stared {
            cell.starMark?.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            cell.starMark?.setImage(UIImage(systemName: "star"), for: .normal)
        }
        cell.starMark?.tag = indexPath.row
        cell.starMark?.addTarget(self, action: #selector(starButtonClicked(_:)), for: .touchUpInside)
        
        
        
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
            shoppingList.remove(at: indexPath.row)
        }
    }
}

//MARK: TextField Delegate
extension ShoppingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !textField.text!.isEmpty {
            shoppingList.append(ShoppingModel(checked: false, text: textField.text!, stared: false))
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

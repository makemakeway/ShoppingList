//
//  ShoppingViewController.swift
//  TableViewPractice
//
//  Created by 박연배 on 2021/10/13.
//

import UIKit
import RealmSwift
import Zip
import MobileCoreServices

class ShoppingViewController: UIViewController {

    
    //MARK: Property
    
    var localRealm = try! Realm()
    
    var tasks: Results<ShoppingItem>!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerContainerView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    //MARK: Method
    
    func documentDirectoryPath() -> String? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
            print(directoryPath)
            return directoryPath
        } else {
            return nil
        }
    }
    
    func presentActivityViewController() {
        // 압축파일 경로를 가져오기
        let fileName = (documentDirectoryPath()! as NSString).appendingPathComponent("archive.zip")
        let fileURL = URL(fileURLWithPath: fileName)
        
        
        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
        self.present(vc, animated: true, completion: nil)
    }
    
    func backupData() {
        // 4. 백업할 파일에 대한 URL 배열
        var urlPaths = [URL]()
        
        // 1. 도큐먼트 폴더 위치
        if let path = documentDirectoryPath() {
            
            // 2. 백업하고자 하는 파일 URL 확인
            // 이미지 같은 경우, 백업 편의성을 위해 폴더를 생성하고, 폴데 안에 이미지를 저장하는 것이 효율적
            let realm = (path as NSString).appendingPathComponent("default.realm")
            
            // 2. 백업하고자 하는 파일 존재 여부 확인
            if FileManager.default.fileExists(atPath: realm) {
                
                // 5. URL 배열에 백업 파일 URL 추가
                urlPaths.append(URL(string: realm)!)
            } else {
                print("DEBUG: 백업할 파일이 없습니다.")
            }
        }
        
        
        // 3. 4번 배열에 대해 압축파일 만들기
        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "archive") // Zip
            
            print("압축 경로: \(zipFilePath)")
            
            print("여기서 ActivityController를 불러오면 된다.")
            presentActivityViewController()
        }
        catch {
          print("DEBUG: 압축파일 만들기 실패")
        }
    }
    
    func restoreData() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeArchive as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func additionalButtonClicked(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let backup = UIAlertAction(title: "백업하기", style: .default) { _ in
            print("백업 실행")
            self.backupData()
        }
        let restore = UIAlertAction(title: "복구하기", style: .default) { _ in
            print("복구 실행")
            self.restoreData()
        }
        let share = UIAlertAction(title: "공유하기", style: .default) { _ in
            print("공유 실행")
            self.presentActivityViewController()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(backup)
        alert.addAction(restore)
        alert.addAction(share)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
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

//MARK: Document Picker Delegate

extension ShoppingViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        // 선택한 파일에 대한 경로 가져오기
        guard let selectedFileURL = urls.first else { return }
        
        // 디렉토리 URL
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // 파일 URL. 디렉토리 경로에 선택한 파일의 경로의 마지막을 붙여놓음.
        let sandboxFileURL = directory.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        
        // 압축 해제
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            do {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentDirectory.appendingPathComponent("archive.zip")
                
                try Zip.unzipFile(fileURL,
                                  destination: documentDirectory,
                                  overwrite: true,
                                  password: nil,
                                  progress: { progress in
                                    print(progress)
                               }, fileOutputHandler: { unzippedFile in
                                    print("unzip: \(unzippedFile)")
                               })
            } catch {
                print("DEBUG: 압축 해제 에러")
            }
        } else {
            // 데이터가 도큐먼트에 없는 경우. 파일 앱의 zip을 도큐먼트 폴더에 복사하고 압축 해제.
            do {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentDirectory.appendingPathComponent("archive.zip")
                
                try Zip.unzipFile(fileURL,
                                  destination: documentDirectory,
                                  overwrite: true,
                                  password: nil,
                                  progress: { progress in
                                    print(progress)
                               }, fileOutputHandler: { unzippedFile in
                                    print("unzip: \(unzippedFile)")
                               })
            } catch {
                print("DEBUG: 압축 해제 에러2")
            }
        }
    }
}

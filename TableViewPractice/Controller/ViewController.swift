//
//  ViewController.swift
//  TableViewPractice
//
//  Created by 박연배 on 2021/10/12.
//

import UIKit

class ViewController: UIViewController {

    //MARK: Property
    @IBOutlet weak var tableView: UITableView!
    
    var titles = ["전체 설정", "개인 설정", "기타"]
    var settings = [["공지사항", "실험실", "버전 정보"], ["개인/보안", "알림", "채팅", "멀티프로필"], ["고객센터/도움말"]]
    
    //MARK: Method
    func tableViewConfig() {
        
    }
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }


}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settings[0].count
        case 1:
            return settings[1].count
        case 2:
            return settings[2].count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "testCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = settings[indexPath.section][indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    // 테이블 뷰 섹션 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title = ""
        switch section {
        case 0:
            title = titles[section]
        case 1:
            title = titles[section]
        case 2:
            title = titles[section]
        default:
            title = ""
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // canEditRowAt -> IndexPath에 맞는 셀의 편집 가능 여부를 결정하는 메소드
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2 ? false : true
    }
    
    // commit editingStyle -> IndexPath와 editingStyle에 맞는 코드를 처리 가능한 메소드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && editingStyle == .delete {
            settings[1].remove(at: indexPath.row)
            tableView.reloadData()
        }
        
    }
    
}

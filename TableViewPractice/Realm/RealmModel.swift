//
//  RealmModel.swift
//  TableViewPractice
//
//  Created by 박연배 on 2021/11/02.
//

import Foundation
import RealmSwift // Realm이 아닌 RealmSwift를 import 해주어야 한다.

class ShoppingItem: Object {
    @Persisted var checked: Bool
    @Persisted var text: String
    @Persisted var stared: Bool
    
    convenience init(checked: Bool, text: String, stared: Bool) {
        self.init()
        self.checked = false
        self.text = text
        self.stared = false
    }
}

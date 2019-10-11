//
//  Todo.swift
//  Findme
//
//  Created by yuhan yin on 6/12/18.
//  Copyright © 2018 mmoaay. All rights reserved.
//

import Foundation
//import Ream
class Todo : NSObject{
    var title: String = ""
    var done : Bool = false
    var date: String = ""
    var showDate = Date()
    var setAlarm : Bool = false
    
    override init() {
        self.title = "unknown todos"
        // default time -current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        date = timeFormatter.string(from: showDate)
        
    }
    
    init(title: String, showDate: Date, setAlarm: Bool) {
        self.title = title
        self.showDate = showDate
        self.setAlarm = setAlarm
    }
    
}


//
//  TodoList+CoreDataProperties.swift
//  
//
//  Created by yuhan yin on 6/23/18.
//
//

import Foundation
import CoreData


extension TodoList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoList> {
        return NSFetchRequest<TodoList>(entityName: "TodoList")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var task: String?
    @NSManaged public var attribute: NSObject?

}

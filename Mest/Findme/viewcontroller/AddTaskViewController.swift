//
//  AddTaskViewController.swift
//  Findme
//
//  Created by yuhan yin on 6/23/18.
//  Copyright © 2018 mmoaay. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController {

    var completed = false
    
    
    @IBOutlet weak var addTextField: UITextField!
    
    @IBAction func done(_ sender: Any) {
        if addTextField.text == nil || addTextField.text == "" {
            print("empty add ")
        } else {
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let manageObjectContext = appDelegate.persistentContainer.viewContext
            
            let newTodo = NSEntityDescription.insertNewObject(forEntityName: "TodoList", into: manageObjectContext) as! TodoList
            newTodo.completed = false
            newTodo.task = addTextField.text
            do {
                try manageObjectContext.save()
                print("Success manageObjectContext.save()")
            } catch {
                print("Failure manageObjectContext.save()")
            }
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
//         addTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

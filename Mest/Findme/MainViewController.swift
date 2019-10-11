//
//  MainViewController.swift
//  Findme
//
//  Created by yuhan yin on 6/12/18.
//  Copyright © 2018 mmoaay. All rights reserved.
//

import UIKit
import CoreLocation
import SwipeCellKit
import CoreData

let kRefreshViewHeight: CGFloat = 400

// MARK: - for search view
extension MainViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        //search data
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let manageObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TodoList", in: manageObjectContext)
        let request = NSFetchRequest<TodoList>(entityName: "TodoList")
        request.fetchOffset = 0
//        request.fetchLimit = 10
        request.entity = entity
        do{
                let results:[AnyObject]? = try manageObjectContext.fetch(request)
                var index = 0
                for todo:TodoList in results as! [TodoList]{
                    if todo.task == searchController.searchBar.text {
                        searchedTodos.append(todo)
                    }
                }
            self.tableView.reloadData()
            
            } catch {
                print("Failed to search the data")
            }
        
    }
    
}

// MARK: - default settings
extension MainViewController{

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchedTodos.count
        } else {
            print(tableView.numberOfSections)
            
            print(todoItems.count)
            return todoItems.count
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return "Matched todos"
        } else {
            return "All todos"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70)
    }
}

// MARK: -

class MainViewController: UITableViewController {
    
    var defaultOptions = SwipeOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    var usesTallCells = false
    
    // add transition
    @IBOutlet weak var addButton: UIBarButtonItem!
    let transition = CircularTransition()
    
    private var refreshView: PullView!
    
    lazy var searchController = ({ () -> UISearchController in
        if let font = UIFont(name: "Futura", size: 16) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.classForCoder() as! UIAppearanceContainer.Type]).defaultTextAttributes = [NSAttributedStringKey.font.rawValue:font, NSAttributedStringKey.foregroundColor.rawValue:UIColor.white]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.classForCoder() as! UIAppearanceContainer.Type]).attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedStringKey.font:font, NSAttributedStringKey.foregroundColor:UIColor.white.withAlphaComponent(0.5)])
            
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.classForCoder() as! UIAppearanceContainer.Type]).tintColor = UIColor.white
        }
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.searchBar.tintColor = UIColor.white
        controller.searchBar.setImage(UIImage(named: "clock_icon"), for: .search, state: .normal)
        controller.searchBar.setImage(UIImage(named: "close"), for: .clear, state: .normal)
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        
        return controller
    })()
    
    var todoItems:[TodoList] = []
    var fetchResultsController: NSFetchedResultsController<TodoList>!
    
    var searchedTodos: [TodoList] = [TodoList](){
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    
//    if let style = fillOption.autoFulFillmentStyle {
//        action.fulfill(with: style)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // all data fetched
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "task", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController.delegate = self
            do {
                try fetchResultsController.performFetch()
                todoItems = fetchResultsController.fetchedObjects!
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        //data delete & search
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let manageObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TodoList", in: manageObjectContext)
        let request = NSFetchRequest<TodoList>(entityName: "TodoList")
        request.fetchOffset = 0
//        request.fetchLimit = 10
        request.entity = entity
//        do{
//            let results:[AnyObject]? = try manageObjectContext.fetch(request)
//            var index = 0
//            for todo:TodoList in results as! [TodoList]{
//                manageObjectContext.delete(todo)
//                print("delete!!!\(todo.task) + \(index)")
//                index = index + 1
//            }
//            try manageObjectContext.save()
//
//            let results2:[AnyObject]? = try manageObjectContext.fetch(request)
//            for todo:TodoList in results2 as! [TodoList]{
//                manageObjectContext.delete(todo)
//                print("todo: \(todo.task)")
//                print("completed: \(todo.completed)")
//            }
//        } catch {
//            print("Failed to modify the data")
//        }
        

        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
//        self.navigationController?.isToolbarHidden = true
        
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        // 自适应单元格高度
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        tableView.backgroundColor = UIColor.white
        view.layoutMargins.left = 32
        // Do any additional setup after loading the view.
        
        // MARK: pull to change the page9
        refreshView = PullView(frame: CGRect(x: 0, y: -kRefreshViewHeight, width: view.bounds.width, height: kRefreshViewHeight), scrollView: tableView)
        refreshView.delegate = self as! PullViewDelegate
        tableView.insertSubview(refreshView, at: 0)
        
        
        
        
       let newTodo = NSEntityDescription.insertNewObject(forEntityName: "TodoList", into: manageObjectContext) as! TodoList
        newTodo.completed = false
        newTodo.task = " finish the core data"
        do {
            try manageObjectContext.save()
            print("Success manageObjectContext.save()")
        } catch {
            print("Failure manageObjectContext.save()")
        }
        
        
        
    }
    
    @objc func reloadTodos() {
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView.tableViewContentOffsetY = tableView.contentOffset.y
        self.navigationItem.leftBarButtonItem?.accessibilityElementsHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
    
//
//    func loadCustomPull() {
////        let pullMenu = Bundle.main.loadNibNamed("MenuView", owner: self, options: nil)
////        menuView = pullMenu![0] as! UIView
//        menuView.frame = pullMenuController.frame
////        print( menuView.subviews.count)
//
//
//
//    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.navigationController?.isNavigationBarHidden = true
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
         print(scrollView.contentOffset)
//        self.navigationController?.isNavigationBarHidden = true
         let sg = ( scrollView.contentOffset.y * -1 ) / 60.0
        self.refreshView.scrollViewDidScroll(scrollView)
        // use main queue to catch the distance
        DispatchQueue.global(qos:
            DispatchQoS.QoSClass.userInitiated).async {
                let distance = scrollView.contentOffset.y
                DispatchQueue.main.async {
                    print(distance)
                    if (distance < -50){
                        
                        
//                       self.loadCustomPull()
//                        self.pullMenuController.addSubview(self.menuView)
//                        self.view.addSubview(self.pullMenuController)
                        
//                        self.addSubview(self.pullMenuController)
                        
//                        print("self.tableView.addSubview")
                        
                        
                    }
                    if (distance < -200){
                        
                    self.performSegue(withIdentifier: "from_todo_to_find", sender: nil)
                    }
                }
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
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

extension MainViewController: SwipeTableViewCellDelegate{
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item = TodoList()
        var i = Double(indexPath.row % 10 )
        print(i)
        if searchController.isActive {
            item = searchedTodos[indexPath.row]
        } else {
            item = todoItems[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTableViewCellIdentifier", for: indexPath) as! TodoTableViewCell
        
        let R : CGFloat = CGFloat((150 + i*8.3)/255)
        let G : CGFloat = CGFloat((210 + i*2.5)/255)
        let B : CGFloat = CGFloat((226 + i*3.6)/255)
        
        cell.delegate = self as! SwipeTableViewCellDelegate
        cell.selectedBackgroundView = createSelectedBackgroundView()
        cell.backgroundColor  = UIColor.init(red: R, green: G, blue: B, alpha: 0.9)
        print(R)
        print(B)
        print(G)
        cell.setTodo(todo: item)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let item = todoItems[indexPath.row]
        
        if orientation == .left {
            guard isSwipeRightEnabled else {return nil}
        
        
            let read = SwipeAction(style: .default, title: nil) { action, indexPath in
                let updatedStatus = !item.completed
                item.completed = updatedStatus
                
                let cell = tableView.cellForRow(at: indexPath) as! TodoTableViewCell
                cell.setUnread(updatedStatus, animated: true)
            }
            read.hidesWhenSelected = true
            read.accessibilityLabel = item.completed ? "Mark as alert" : "Mark as Unalert"
            let descriptor: ActionDescriptor = item.completed ? .read : .unread
            configure(action: read, with: descriptor)
            
            return [read]
        } else {
            let flag = SwipeAction(style: .default, title: nil, handler: nil)
            flag.hidesWhenSelected = true
            configure(action: flag, with: .flag)
            
            let delete = SwipeAction(style: .destructive, title: nil) { [unowned self]action, indexPath in
//                self.tableView.setEditing(false, animated: true)
                self.removeTodo(indexPath: indexPath)
//                self.todoItems.
            }
            configure(action: delete, with: .trash)
            return [delete, flag]
        }
    }
    //data source
    func createSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }
    
    
    func visibleRect(for tableView: UITableView) -> CGRect? {
        if usesTallCells == false { return nil }
        
        if #available(iOS 11.0, *) {
            return tableView.safeAreaLayoutGuide.layoutFrame
        } else {
            let topInset = navigationController?.navigationBar.frame.height ?? 0
            let bottomInset = navigationController?.toolbar?.frame.height ?? 0
            let bounds = tableView.bounds
            
            return CGRect(x: bounds.origin.x, y: bounds.origin.y + topInset, width: bounds.width, height: bounds.height - bottomInset)
        }
    }

     func removeTodo(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete this Todo?", message: "Are you sure to delete this todo?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [unowned self] action in
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let manageObjectContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "TodoList", in: manageObjectContext)
            let request = NSFetchRequest<TodoList>(entityName: "TodoList")
            request.fetchOffset = 0
            request.entity = entity
            
            var item = TodoList()
            if self.searchController.isActive{
                item = self.searchedTodos[indexPath.row]
                
            } else {
                item = self.todoItems[indexPath.row]
            }
            
            do{
                manageObjectContext.delete(item)
                try manageObjectContext.save()
                print("delete!!!\(item.task)")
            } catch {
                print("Failed to delete the data")
            }

//            self.tableView.reloadData()
            
        }
        let cancel = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
         options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        }
        
        return options
    }
    
    func buttonDisplayModeTapped() {
        let controller = UIAlertController(title: "Button Display Mode", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Image + Title", style: .default, handler: { _ in self.buttonDisplayMode = .titleAndImage }))
        controller.addAction(UIAlertAction(title: "Image Only", style: .default, handler: { _ in self.buttonDisplayMode = .imageOnly }))
        controller.addAction(UIAlertAction(title: "Title Only", style: .default, handler: { _ in self.buttonDisplayMode = .titleOnly }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func buttonStyleTapped() {
        let controller = UIAlertController(title: "Button Style", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Background Color", style: .default, handler: { _ in
            self.buttonStyle = .backgroundColor
            self.defaultOptions.transitionStyle = .border
        }))
        controller.addAction(UIAlertAction(title: "Circular", style: .default, handler: { _ in
            self.buttonStyle = .circular
            self.defaultOptions.transitionStyle = .reveal
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func cellHeightTapped() {
        let controller = UIAlertController(title: "Cell Height", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Normal", style: .default, handler: { _ in
            self.usesTallCells = false
            self.tableView.reloadData()
        }))
        controller.addAction(UIAlertAction(title: "Tall", style: .default, handler: { _ in
            self.usesTallCells = true
            self.tableView.reloadData()
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    
}

extension MainViewController: PullViewDelegate {
    func refreshViewDidFinish(refreshView: PullView) {
//        sleep(3)
        refreshView.endRefreshing()
    }
}

// fetch the core data
extension MainViewController: NSFetchedResultsControllerDelegate{
    // MARK: - Fetch results controller delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert: guard let indexPath = newIndexPath else { break }
        tableView.insertRows(at: [indexPath], with: .fade)
        case .delete: guard let indexPath = indexPath else { break }
        tableView.deleteRows(at: [indexPath], with: .fade)
        case .update: guard let indexPath = indexPath else { break }
        tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            tableView.reloadData()
        }
        todoItems = controller.fetchedObjects as! [TodoList]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Strike through text function
    
    func strikeThroughText (_ text:String) -> NSAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    
}


// trasition the view
extension MainViewController: UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = CGPoint.init(x: 300, y: 300)
        transition.circleColor = UIColor.green
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint.init(x: 100, y: 100)
        transition.circleColor =  UIColor.green
        
        return transition
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTaskSegue" {
            let secondVC = segue.destination as! AddTaskViewController
            secondVC.transitioningDelegate = self
            secondVC.modalPresentationStyle = .custom
        }
    }
    
    
}

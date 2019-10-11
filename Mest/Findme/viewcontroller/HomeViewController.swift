//
//  HomeViewController.swift
//  Findme
//
//  Created by zhengperry on 2017/9/24.
//  Copyright © 2017年 mmoaay. All rights reserved.
//

import UIKit
import SceneKit
import CoreLocation


extension HomeViewController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) {
        searchedRoutes =  RouteCacheService.shared.routes(prefix: searchController.searchBar.text!)
    }
}

extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ("from_home_to_search" == segue.identifier) {
            if let destination = segue.destination as? SearchSceneViewController, let item = sender as? Route {
                destination.route = item
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = Route()
        if searchController.isActive {
            item = searchedRoutes[indexPath.row];
        } else {
            item = routes[indexPath.row]
        }
        performSegue(withIdentifier: "from_home_to_search", sender: item)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchedRoutes.count
        } else {
            return routes.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return "Matched routes"
        } else {
            return "All the routes"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item = Route()
        if searchController.isActive {
            item = searchedRoutes[indexPath.row];
        } else {
            item = routes[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCellIdentifier", for: indexPath) as! HomeTableViewCell
        cell.setRoute(route: item)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "delete") {[unowned self] action, indexPath  in
            self.tableView.setEditing(false, animated: true)
            self.removeRoute(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor(hexColor: "CD4F39")
        
        let share = UITableViewRowAction(style: .normal, title: "share") { [unowned self] action, indexPath  in
            self.tableView.setEditing(false, animated: true)
            self.shareRoute(indexPath: indexPath)
        }
        share.backgroundColor = UIColor(hexColor: "96D2E2")
        
        return [delete, share]
    }
    
    private func removeRoute(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Route", message: "Are you sure to delete this route?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Yes", style: .default) { [unowned self] action in
            var item = Route()
            if self.searchController.isActive {
                item = self.searchedRoutes[indexPath.row];
            } else {
                item = self.routes[indexPath.row]
            }
            RouteCacheService.shared.delRoute(route: item)
            self.routes = RouteCacheService.shared.allRoutes()
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func shareRoute(indexPath: IndexPath) {
        var item = Route()
        if searchController.isActive {
            item = searchedRoutes[indexPath.row];
        } else {
            item = routes[indexPath.row]
        }
        ShareUtil.shared.shareRoute(view: self.view, identity: item.identity)
    }
}

extension HomeViewController: PullViewDelegate{
    func refreshViewDidFinish(refreshView: PullView) {
        refreshView.endRefreshing()
    }

    
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
                    if (distance < -200){
                        
                        self.performSegue(withIdentifier: "from_home_to_list", sender: nil)
                    }
                }
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}
class HomeViewController: UITableViewController {
    
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
    
    lazy var routes: [Route] = RouteCacheService.shared.allRoutes()
    
    var searchedRoutes: [Route] = [Route](){
        didSet {
            self.tableView.reloadData()
        }
    }
    private var refreshView: PullView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        // Do any additional setup after loading the view.
        
        reloadRoutes()
        
        refreshView = PullView(frame: CGRect(x: 0, y: -kRefreshViewHeight, width: view.bounds.width, height: kRefreshViewHeight), scrollView: tableView)
        refreshView.delegate = self as! PullViewDelegate
        tableView.insertSubview(refreshView, at: 0)
        

        NotificationCenter.default.addObserver(self, selector: #selector(reloadRoutes), name: NSNotification.Name(rawValue: "ReloadRoutes"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReloadRoutes"), object: nil)
    }
    
    @objc func reloadRoutes() {
        routes = RouteCacheService.shared.allRoutes()
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          refreshView.tableViewContentOffsetY = tableView.contentOffset.y
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

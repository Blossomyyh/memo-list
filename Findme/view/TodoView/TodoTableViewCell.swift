//
//  TodoTableViewCell.swift
//  Findme
//
//  Created by yuhan yin on 6/13/18.
//  Copyright © 2018 mmoaay. All rights reserved.
//

import UIKit
import SwipeCellKit
class TodoTableViewCell: SwipeTableViewCell {

//    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var title: UITextField!
    @IBOutlet weak var complete: UIImageView!
    var indicatorView = IndicatorView(frame: .zero)
    
    var animator: Any?
    var unread = false {
        didSet {
            indicatorView.transform = unread ? CGAffineTransform.identity : CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        }
    }
    
    override func awakeFromNib() {
//        self.layoutMargins.left = 32
        super.awakeFromNib()
        title.borderStyle = .none
        title.backgroundColor = UIColor.init(named: "#96D2E2")
        setupIndicatorView()
    }

    func setupIndicatorView() {
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.color = tintColor
        indicatorView.backgroundColor = .clear
        contentView.addSubview(indicatorView)
        
        let size: CGFloat = 12
        indicatorView.widthAnchor.constraint(equalToConstant: size).isActive = true
        indicatorView.heightAnchor.constraint(equalTo: indicatorView.widthAnchor).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo:title.leftAnchor, constant: -16).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
    }
    
    func setUnread(_ unread: Bool, animated: Bool) {
        let closure = {
            self.unread = unread
        }
        if #available(iOS 10, *), animated {
            var localAnimator = self.animator as? UIViewPropertyAnimator
            localAnimator?.stopAnimation(true)
            
            localAnimator = unread ? UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.4) : UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1.0)
            localAnimator?.addAnimations(closure)
            localAnimator?.startAnimation()
            
            self.animator = localAnimator
        } else {
            closure()
        }
    }
    
    func setTodo(todo: TodoList){
        title.text = todo.task
        if (todo.completed == true) {
            complete.image = #imageLiteral(resourceName: "ok")
        } else {
            complete.image = #imageLiteral(resourceName: "non")
        }
        title.font = UIFont(name: "Futura", size: 16)
        if let font = UIFont(name: "Futura", size: 16) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.classForCoder() as! UIAppearanceContainer.Type]).defaultTextAttributes = [NSAttributedStringKey.font.rawValue:font, NSAttributedStringKey.foregroundColor.rawValue:UIColor.white]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.classForCoder() as! UIAppearanceContainer.Type]).attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedStringKey.font:font, NSAttributedStringKey.foregroundColor:UIColor.white.withAlphaComponent(0.5)])
            
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.classForCoder() as! UIAppearanceContainer.Type]).tintColor = UIColor.white
        }
    
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

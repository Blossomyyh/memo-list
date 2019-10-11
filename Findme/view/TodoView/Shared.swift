//
//  Shared.swift
//  Findme
//
//  Created by yuhan yin on 6/13/18.
//  Copyright © 2018 mmoaay. All rights reserved.
//

import Foundation
import UIKit
class IndicatorView: UIView {
    var color = UIColor.clear {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        UIBezierPath(ovalIn: rect).fill()
    }
}

enum ActionDescriptor {
    case read, unread, more, flag, trash
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .read: return "Read"
        case .unread: return "Unread"
        case .more: return "More"
        case .flag: return "Flag"
        case .trash: return "Trash"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .read: name = "Read"
        case .unread: name = "Unread"
        case .more: name = "More"
        case .flag: name = "Flag"
        case .trash: name = "Trash"
        }
        
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    }
    
    var color: UIColor {
        switch self {
        case .read, .unread: return UIColor.init(red: 144/255, green: 148/255, blue: 212/255, alpha: 1)
        case .more: return #colorLiteral(red: 0.6069424748, green: 0.8005788922, blue: 0.4807519913, alpha: 1)
        case .flag: return UIColor.init(red: 249/255, green: 216/255, blue: 123/255, alpha: 1)
        case .trash: return UIColor.init(red: 233/255, green: 185/255, blue: 190/255, alpha: 1)
        }
    }
}
enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}

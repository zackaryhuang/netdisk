//
//  ABProgressHUD.swift
//  ABCloud
//
//  Created by Zackary Huang on 2024/5/1.
//

import Foundation
import AppKit
import SnapKit

class ABProgressHUD {
    
    static let hud = ABProgressHUD()
    
    let activityIndicatorView: NSProgressIndicator
    
    func startAnimatingView(inView: NSView? = nil) {
        if activityIndicatorView.superview == nil {
            guard let contentView = inView ?? NSApplication.shared.windows.first?.contentView else { return }
            contentView.addSubview(activityIndicatorView)
            activityIndicatorView.snp.makeConstraints { make in
                make.center.equalTo(contentView)
                make.width.height.equalTo(30)
            }
//            contentView.frame = contentView.bounds
        }
        activityIndicatorView.startAnimation(nil)
        activityIndicatorView.isHidden = false
    }

    func stopAnimatingView() {
        activityIndicatorView.stopAnimation(nil)
        activityIndicatorView.isHidden = true
        activityIndicatorView.removeFromSuperview()
    }
    
    class func showHUD() {
        hud.startAnimatingView()
    }
    
    class func hideHUD() {
        hud.stopAnimatingView()
    }
    
    init() {
        activityIndicatorView = NSProgressIndicator()
        activityIndicatorView.controlSize = .small
        activityIndicatorView.style = .spinning
    }
}

extension NSView {
    func showHUD() {
        ABProgressHUD.hud.startAnimatingView(inView: self)
    }
    
    func hideHUD() {
        ABProgressHUD.hud.stopAnimatingView()
    }
}

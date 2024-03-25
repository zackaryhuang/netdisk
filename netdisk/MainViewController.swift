//
//  MainViewController.swift
//  netdisk
//
//  Created by Zackary on 2023/8/30.
//

import Cocoa
import SnapKit
import Alamofire
import Kingfisher

enum CategoryType {
    case downloading
    case uploading
    case finishedTrans
    case files
    case photos
    case videos
    case audios
    case docs
}

class MainViewController: NSViewController {
    
    let sidePanel = SidePanelView()
    
    let subSidePanel = SubSidePanelView()
    
    var VCs = [any CategoryVC]()
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x111114).cgColor
        self.view = view
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin), name: NSNotification.Name(Const.DidLoginNotificationName), object: nil)
    }
    
    private func configUI() {
        view.addSubview(sidePanel)
        sidePanel.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(view)
            make.width.equalTo(79)
        }
        
        view.addSubview(subSidePanel)
        subSidePanel.delegate = self
        subSidePanel.snp.makeConstraints { make in
            make.leading.equalTo(sidePanel.snp.trailing)
            make.width.equalTo(168)
            make.top.bottom.equalTo(view)
        }
        
        let sepLine = NSView()
        sepLine.wantsLayer = true
        sepLine.layer?.backgroundColor = NSColor(hex: 0x1A1A1C).cgColor
        view.addSubview(sepLine)
        sepLine.snp.makeConstraints { make in
            make.leading.equalTo(subSidePanel.snp.trailing)
            make.top.bottom.equalTo(view)
            make.width.equalTo(0.5)
        }
        
        sidePanel.delegate = subSidePanel
        
        let fileListVC = FileListViewController()
        addChild(fileListVC)
        view.addSubview(fileListVC.view)
        VCs.append(fileListVC)
        fileListVC.view.snp.makeConstraints { make in
            make.leading.equalTo(subSidePanel.snp.trailing)
            make.top.bottom.trailing.equalTo(view)
        }
        
        let downloadListVC = DownloadListViewController()
        downloadListVC.view.isHidden = true
        addChild(downloadListVC)
        view.addSubview(downloadListVC.view)
        VCs.append(downloadListVC)
        downloadListVC.view.snp.makeConstraints { make in
            make.leading.equalTo(subSidePanel.snp.trailing)
            make.top.bottom.trailing.equalTo(view)
        }
        
        let resourceListVC = ResourceListViewController()
        resourceListVC.view.isHidden = true
        addChild(resourceListVC)
        view.addSubview(resourceListVC.view)
        VCs.append(resourceListVC)
        resourceListVC.view.snp.makeConstraints { make in
            make.leading.equalTo(subSidePanel.snp.trailing)
            make.top.bottom.trailing.equalTo(view)
        }
    }
    
    @objc func didLogin() {
        sidePanel.avatarImageView.kf.setImage(with: ClientManager.shared.userData?.avatarURL)
    }
}

extension MainViewController: SubSidePanelViewDelegate {
    func didSelect(itemType: SubSidePanelItemType) {
        VCs.forEach { viewController in
            viewController.view.isHidden = viewController.categoryType != itemType
        }
    }
}

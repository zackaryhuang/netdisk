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
    
    var VCs = [any CategoryVC]()
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x1F1F22).cgColor
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        NotificationCenter.default.addObserver(self, selector: #selector(didLogin), name: NSNotification.Name(Const.DidLoginNotificationName), object: nil)
    }
    
    private func configUI() {
        sidePanel.delegate = self
        view.addSubview(sidePanel)
        sidePanel.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(view)
            make.width.equalTo(78)
        }
        
        let fileListVC = FileListViewController()
        addChild(fileListVC)
        view.addSubview(fileListVC.view)
        VCs.append(fileListVC)
        fileListVC.view.snp.makeConstraints { make in
            make.leading.equalTo(sidePanel.snp.trailing)
            make.top.bottom.trailing.equalTo(view)
        }
        
        let searchListVC = SearchFileListViewController()
        searchListVC.view.isHidden = true
        addChild(searchListVC)
        view.addSubview(searchListVC.view)
        VCs.append(searchListVC)
        searchListVC.view.snp.makeConstraints { make in
            make.leading.equalTo(sidePanel.snp.trailing)
            make.top.bottom.trailing.equalTo(view)
        }
        
        let downloadListVC = DownloadListViewController()
        downloadListVC.view.isHidden = true
        addChild(downloadListVC)
        view.addSubview(downloadListVC.view)
        VCs.append(downloadListVC)
        downloadListVC.view.snp.makeConstraints { make in
            make.leading.equalTo(sidePanel.snp.trailing)
            make.top.bottom.trailing.equalTo(view)
        }
    }
    
    @objc func didLogin() {
        sidePanel.avatarImageView.kf.setImage(with: ClientManager.shared.userData?.avatarURL)
    }
}

extension MainViewController: SidePanelViewDelegate {
    func didSelect(tab: MainCategoryType) {
        VCs.forEach { categoryVC in
            categoryVC.view.isHidden = categoryVC.categoryType != tab
        }
    }
}

//
//  LoginViewController.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
//

import Cocoa
import SnapKit
import Alamofire
import Kingfisher

class LoginViewController: NSViewController {

    let imageView = NSImageView()
    var qrCodeData: (any QRCodeData)?
    
    lazy var expiredView = {
        let view = NSView()
        let imageView = NSImageView()
        imageView.image = NSImage(named: "icon_refresh")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        return view
    }()
    
    weak var windowController: MainWindowController?
    
    let scanTipsLabel = {
        let textField = NSTextField(labelWithString: ClientManager.shared.currentClient() == .Baidu ? "扫码登录百度网盘" : "扫码登录阿里云盘")
        textField.isEditable = false
        textField.drawsBackground = false
        textField.font = NSFont(PingFang: 16)
        textField.textColor = NSColor(hex: 0x459D53)
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(170)
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(79)
        }
        
        view.addSubview(scanTipsLabel)
        scanTipsLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(imageView.snp.bottom).offset(24)
        }
        
        requestUrl()
    }
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x272727).cgColor
        self.view = view
    }
    
    func requestUrl() {
        Task {
            if let data = try? await WebRequest.requestLoginQRCode() {
                qrCodeData = data
                self.imageView.kf.setImage(with: URL(string: data.qrCodeUrl)) { result in
                    switch result {
                    case .success:
                        self.expiredView.removeFromSuperview()
                        self.queryAccessToken()
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func queryAccessToken() {
        if let code = qrCodeData?.code {
            Task {
                let qrCodeStatus = try? await WebRequest.queryQRCodeScanStatus(code: code)
                if qrCodeStatus == .AuthSuccess {
                    self.windowController?.loginSuccess()
                } else if qrCodeStatus == .QRCodeExpired {
                    self.imageView.addSubview(self.expiredView)
                    self.expiredView.snp.makeConstraints { make in
                        make.edges.equalTo(self.imageView)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(WebRequest.shared.baiduQueryInterval), execute: DispatchWorkItem(block: { [weak self] in
                        self?.queryAccessToken()
                    }))
                }
            }
        }
    }
}

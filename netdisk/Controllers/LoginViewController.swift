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
        let textField = NSTextField(labelWithString: ZigClientManager.shared.currentClient() == .Baidu ? "扫码登录百度网盘" : "扫码登录阿里云盘")
        textField.isEditable = false
        textField.drawsBackground = false
        textField.font = NSFont(PingFang: 16)
        textField.textColor = NSColor(hex: 0x637DFF)
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor(hex: 0xFFFFFF).cgColor
        containerView.layer?.cornerRadius = 20
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(40)
            make.trailing.equalTo(view).offset(-40)
            make.top.equalTo(view).offset(60)
            make.bottom.equalTo(view).offset(-40)
        }

        containerView.addSubview(imageView)
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 10
        imageView.layer?.shadowOffset = CGSize(width: 2, height: 2)
        imageView.layer?.shadowColor = NSColor(hex: 0x000000, alpha: 0.1).cgColor
        imageView.layer?.shadowRadius = 5
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(170)
            make.centerX.equalTo(containerView)
            make.top.equalTo(containerView).offset(30)
        }
        
        containerView.addSubview(scanTipsLabel)
        scanTipsLabel.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.top.equalTo(imageView.snp.bottom).offset(24)
        }
        
        requestUrl()
    }
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0xEDEFFF).cgColor
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

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
import QRCode

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
        containerView.layer?.backgroundColor = NSColor(hex: 0x222226).cgColor
        containerView.layer?.cornerRadius = 20
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(40)
            make.trailing.equalTo(view).offset(-40)
            make.centerY.equalTo(view)
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
            make.top.equalTo(containerView).offset(20)
        }
        
        containerView.addSubview(scanTipsLabel)
        scanTipsLabel.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.bottom.equalTo(containerView).offset(-20)
        }
        
        requestUrl()
    }
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: 0x111114).cgColor
        self.view = view
    }
    
    func requestUrl() {
        Task {
            if let data = try? await WebRequest.requestLoginQRCode() {
                qrCodeData = data
                if let doc = QRCode.Document("https://www.aliyundrive.com/o/oauth/authorize?sid=\(data.code)") {
                    doc.design.backgroundColor(NSColor.white.cgColor)
                    doc.design.shape.eye = QRCode.EyeShape.RoundedOuter()
                    doc.design.shape.onPixels = QRCode.PixelShape.Circle()
                    doc.design.style.onPixels = QRCode.FillStyle.Solid(NSColor(hex: 0x8DE6FA).cgColor)
                    doc.design.shape.offPixels = QRCode.PixelShape.Horizontal(insetFraction: 4, cornerRadiusFraction: 2)
                    doc.design.foregroundColor(NSColor(hex: 0x0642C7).cgColor)
                    doc.design.style.offPixels = QRCode.FillStyle.Solid(NSColor(hex: 0x19BAFB).cgColor)
                    
                    // Set a custom pupil shape. If this isn't set, the default pixel shape for the eye is used
                    doc.design.shape.pupil = QRCode.PupilShape.BarsHorizontal()
                    doc.logoTemplate = .SquareCenter(image: NSImage(named: "image_qrcode")!.cgImage!)
                    
                    let qrCodeWithLogo = doc.nsImage(dimension: 340)
                    self.imageView.image = qrCodeWithLogo
                    self.expiredView.removeFromSuperview()
                    self.queryAccessToken()
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

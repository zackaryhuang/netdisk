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
    var deviceCodeData: DeviceCodeData?
    
    let scanTipsLabel = {
        let textField = NSTextField(labelWithString: "扫码登录百度网盘")
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
        AF.request("https://openapi.baidu.com/oauth/2.0/device/code", method: .post, parameters: ["response_type" : "device_code", "client_id" : "8xVGfuF1lIpiyqO1KSSTs8fC0H3VIRHd", "scope" : "basic,netdisk"]).responseDecodable(of: DeviceCodeData.self) { response in
            
            self.deviceCodeData = response.value
            
            if let url_string = response.value?.QRCodeUrl {
                self.imageView.kf.setImage(with: URL(string: url_string)) { result in
                    switch result {
                    case .success:
                        self.queryAccessToken()
                    case .failure(let error):
                        print("Job failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func setImageWithUrl(url: String) {
        let image = generateCode(inputMsg: url)
        imageView.image = image
    }
    
    func queryAccessToken() {
        if let deviceCode = self.deviceCodeData?.deviceCode {
            AF.request("https://openapi.baidu.com/oauth/2.0/token", method: .post, parameters: ["grant_type" : "device_token", "code" : deviceCode, "client_id" : "8xVGfuF1lIpiyqO1KSSTs8fC0H3VIRHd", "client_secret" : "OsQkHVyNecu5U3rHyquwdegQGy9HPItD"]).responseDecodable(of: AccessTokenData.self) { response in
                if let accessToken = response.value?.accessToken,
                    let refreshToken = response.value?.refreshToken {
                    print("AccessToken: \(accessToken), RefreshToken: \(refreshToken)")
                    UserDefaults.standard.set(accessToken, forKey: "UserAccessToken")
                    UserDefaults.standard.set(refreshToken, forKey: "UserRefreshToken")
                } else {
                    if let interval = self.deviceCodeData?.interval  {
                        DispatchQueue.global().asyncAfter(deadline:  DispatchTime.now() + DispatchTimeInterval.seconds(interval)) {
                            self.queryAccessToken()
                        }
                    }
                }
            }
        }
    }
    
    func generateCode(inputMsg: String) -> NSImage {
        //1. 将内容生成二维码
        //1.1 创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        //1.2 恢复默认设置
        filter?.setDefaults()
        
        //1.3 设置生成的二维码的容错率
        //value = @"L/M/Q/H"
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        
        // 2.设置输入的内容(KVC)
        // 注意:key = inputMessage, value必须是NSData类型
        let inputData = inputMsg.data(using: .utf8)
        filter?.setValue(inputData, forKey: "inputMessage")
        
        //3. 获取输出的图片
        guard let outImage = filter?.outputImage else { return NSImage() }
        
        //4. 获取高清图片
        let hdImage = getHDImage(outImage)
        
        //6. 获取有前景图片的二维码
        return hdImage
    }
    
    //4. 获取高清图片
    fileprivate func getHDImage(_ outImage: CIImage) -> NSImage {
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        //放大图片
        let ciImage = outImage.transformed(by: transform)
        
        let rep = NSCIImageRep(ciImage: ciImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }

    
}


class DeviceCodeData: Codable {
    
    let deviceCode: String?
    let QRCodeUrl: String?
    let userCode: String?
    let expiresIn: Int?
    let interval: Int?
    
    enum CodingKeys: String, CodingKey {
        case deviceCode = "device_code"
        case QRCodeUrl = "qrcode_url"
        case userCode = "user_code"
        case expiresIn = "expires_in"
        case interval = "interval"
    }
}

class AccessTokenData: Codable {
    let accessToken: String?
    let refreshToken: String?
    let expiresIn: Int?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

//
//  ImagePreviewController.swift
//  netdisk
//
//  Created by Zackary on 2023/9/9.
//

import Cocoa
import Alamofire
import SnapKit

class ImagePreviewController: NSViewController {

    var detailInfo: FileDetailInfo?
    weak var window: NSWindow?
    let imageView = {
        let view = NSImageView()
        view.wantsLayer = true
        view.layer?.contentsGravity = .resizeAspectFill
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(view)
            make.width.equalTo(720)
            make.height.equalTo(576)
        }
        
        if let url3 = detailInfo?.thumbs?["url3"] as? String {
            imageView.kf.setImage(with: URL(string: url3))
        }
        
        if let url = detailInfo?.downloadLink {
            AF.download(url, parameters: ["access_token" : UserDefaults.standard.object(forKey: "UserAccessToken") as! String], headers: ["User-Agent" : "pan.baidu.com"] ,to: DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory, options: .removePreviousFile)).response { response in
                switch response.result {
                case .success:
                    if let path = response.value as? URL,
                       let image = NSImage(contentsOf: path) {
                        let ratio = image.size.height / image.size.width
                        let height = 576.0
                        let width = height / ratio
                        self.imageView.snp.remakeConstraints { make in
                            make.edges.equalTo(self.view)
                            make.width.equalTo(width)
                            make.height.equalTo(height)
                        }
                        self.imageView.image = image
                    }
                    self.window?.center()
                    debugPrint("success")
                case let .failure(err):
                    debugPrint("下载图片失败\(err.localizedDescription)")
                }
            }
            
        }
    }
    
    
    override func loadView() {
        let view = NSView()
        self.view = view
    }
}

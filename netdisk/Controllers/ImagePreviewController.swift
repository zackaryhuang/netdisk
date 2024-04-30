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

    var detailInfo: (any FileDetail)?
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
//            make.width.equalTo(720)
//            make.height.equalTo(576)
        }
        
        if let previewURL = detailInfo?.previewURL {
            imageView.kf.setImage(with: previewURL)
        }
        
        guard let fileID = detailInfo?.fileID else { return }
        
        Task {
            guard let downloadInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID),
            let downloadURL = downloadInfo.downloadURL else { return }
            imageView.kf.cancelDownloadTask()
            imageView.kf.setImage(with: downloadURL)
        }
        
        
//        if let url = detailInfo?.downloadLink {
//            AF.download(url, parameters: ["access_token" : UserDefaults.standard.object(forKey: "UserAccessToken") as! String], headers: ["User-Agent" : "pan.baidu.com"] ,to: DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory, options: .removePreviousFile)).response { response in
//                switch response.result {
//                case .success:
//                    DispatchQueue.global().async {
//                        if let path = response.value as? URL,
//                           let image = NSImage(contentsOf: path) {
//                            let ratio = image.size.height / image.size.width
//                            let height = 576.0
//                            let width = height / ratio
//                            DispatchQueue.main.async {
//                                self.imageView.image = image
//                                
//                                let oldX = self.window?.frame.origin.x ?? 0.0
//                                let oldY = self.window?.frame.origin.y ?? 0.0
//                                let oldW = self.window?.frame.size.width ?? 0.0
//                                let oldH = self.window?.frame.size.height ?? 0.0
//                                
//                                let oldCenter = CGPoint(x: oldX + oldW / 2.0, y: oldY + oldH / 2.0)
//                                
//                                let newW = width
//                                let newH = height
//                                let newX = oldCenter.x - newW / 2.0
//                                
//                                let newY = oldCenter.y - newH / 2.0
//                                
//                                NSAnimationContext.runAnimationGroup({context in
//                                  context.duration = 0.25
//                                  context.allowsImplicitAnimation = true
//                                  
//                                    self.imageView.snp.remakeConstraints { make in
//                                        make.edges.equalTo(self.view).inset(NSEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
//                                        make.width.equalTo(width)
//                                        make.height.equalTo(height)
//                                    }
//                                    self.view.layoutSubtreeIfNeeded()
////                                    self.window?.setFrameOrigin(CGPoint(x: newX, y: newY))
//                                    self.window?.setFrame(NSMakeRect(newX - 50, newY - 50, newW + 100, newH + 100), display: true)
//                                  
//                                }, completionHandler:nil)
//                            }
//                        }
//                    }
//                    debugPrint("success")
//                case let .failure(err):
//                    debugPrint("下载图片失败\(err.localizedDescription)")
//                }
//            }
//            
//        }
    }
    
    
    override func loadView() {
        let view = NSView()
        self.view = view
    }
}

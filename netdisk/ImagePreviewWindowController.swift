//
//  MainWindowController.swift
//  netdisk
//
//  Created by Zackary on 2023/8/29.
//

import Cocoa
import Kingfisher
import Alamofire

class ImagePreviewWindowController: NSWindowController, NSWindowDelegate {
    
    var detailInfo: AliFileDetail?
    
    let imagePreviewController = ImagePreviewController()
    
    let imageView = {
        let view = ABImageView()
        return view
    }()
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        guard let contentView = self.window?.contentView else { return }
        contentView.addSubview(imageView)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        var bottom = 50.0
        if detailInfo?.imageMedia?.exifInfo != nil {
            bottom = 100.0
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(NSEdgeInsets(top: 50, left: 50, bottom: bottom, right: 50))
        }
        
        imageView.kf.setImage(with: detailInfo?.previewURL) { _ in
            guard let fileID = self.detailInfo?.fileID else { return }
            
            Task {
                guard let downloadInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID),
                let downloadURL = downloadInfo.downloadURL else { return }
                self.imageView.kf.setImage(with: downloadURL, placeholder: self.imageView.image)
            }
        }
        
        guard let exif = detailInfo?.imageMedia?.exifInfo else { return }
        
        let modelLabel = ZigLabel()
        modelLabel.font = NSFont(PingFangSemiBold: 20)
        contentView.addSubview(modelLabel)
        modelLabel.textColor = .white
        modelLabel.stringValue = exif.Model?.value ?? ""
        modelLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView).offset(50)
            make.top.equalTo(imageView.snp.bottom).offset(20)
        }
        
        let timeLabel = ZigLabel()
        modelLabel.font = NSFont(PingFang: 18)
        contentView.addSubview(timeLabel)
        timeLabel.textColor = .white
        timeLabel.stringValue = detailInfo?.imageMedia?.time ?? ""
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView).offset(50)
            make.bottom.equalTo(contentView).offset(-20)
        }
        
        let paramsLabel = ZigLabel()
        paramsLabel.font = NSFont(PingFang: 18)
        paramsLabel.alignment = .left
        contentView.addSubview(paramsLabel)
        paramsLabel.textColor = .white
        paramsLabel.stringValue = "\(exif.ExposureTime?.value ?? "") \(exif.FNumber?.value ?? "") \(exif.FocalLengthIn35mmFilm?.value ?? "")"
        paramsLabel.snp.makeConstraints { make in
            make.trailing.equalTo(imageView).offset(-50)
            make.centerY.equalTo(modelLabel)
        }
        
        let lenModelLabel = ZigLabel()
        lenModelLabel.alignment = .left
        lenModelLabel.font = NSFont(PingFang: 18)
        contentView.addSubview(lenModelLabel)
        lenModelLabel.textColor = .white
        lenModelLabel.stringValue = exif.LensModel?.value ?? ""
        lenModelLabel.snp.makeConstraints { make in
            make.trailing.equalTo(paramsLabel)
            make.leading.equalTo(paramsLabel)
            make.centerY.equalTo(timeLabel)
        }
    }
    
    override func loadWindow() {
        var width = 280.0, height = 400.0
        var maxHeight = 600.0, maxWidth = 600.0
        if let imageWidth = detailInfo?.imageMedia?.width, let imageHeight = detailInfo?.imageMedia?.height {
            let w_h_ration = Double(imageWidth) / Double(imageHeight)
            if imageWidth > imageHeight {
                width = min(maxWidth, Double(imageWidth))
                height = width / w_h_ration
            } else {
                height = min(maxHeight, Double(imageHeight))
                width = height * w_h_ration
            }
            width += 100
            height += 150
        }
        let frame: CGRect = CGRect(x: 0, y: 0, width: width, height: height)
        let style: NSWindow.StyleMask = [.titled, .closable, .fullSizeContentView]
        let back: NSWindow.BackingStoreType = .buffered
        let window: NSWindow = NSWindow(contentRect: frame, styleMask: style, backing: back, defer: false)
        window.titlebarAppearsTransparent = true
//        window.maxSize = NSMakeSize(maxWidth, maxHeight)
        window.center()
        window.delegate = self
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        self.window = window
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        exit(0)
    }
}

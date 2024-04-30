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
    
    static let padding = 30.0
    static let bottomHeight = 50.0
    
    var detailInfo: AliFileDetail?
    
    let imagePreviewController = ImagePreviewController()
    
    let imageView = {
        let view = ABImageView()
        view.contentMode = .aspectFit
        return view
    }()
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.backgroundColor = NSColor.black
        guard let contentView = self.window?.contentView else { return }
        contentView.addSubview(imageView)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        var bottom = Self.padding
        if (detailInfo?.imageMedia?.exifInfo?.isVaild ?? false) {
            bottom += Self.bottomHeight
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(NSEdgeInsets(top: Self.padding, left: Self.padding, bottom: bottom, right: Self.padding))
        }
        
        imageView.kf.setImage(with: detailInfo?.previewURL) { _ in
            guard let fileID = self.detailInfo?.fileID else { return }
            
            Task {
                guard let downloadInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID),
                let downloadURL = downloadInfo.downloadURL else { return }
                self.imageView.kf.setImage(with: downloadURL, placeholder: self.imageView.image)
            }
        }
        
        guard let exif = detailInfo?.imageMedia?.exifInfo,
              exif.isVaild,
              let modelName = exif.Model?.value,
              let cTime = detailInfo?.imageMedia?.time,
              let exposureTime = exif.ExposureTime?.value,
              let fNumber = exif.FNumber?.value,
              let focalLength = exif.FocalLengthIn35mmFilm?.value,
              let lensModel = exif.LensModel?.value else { return }
        
        let modelLabel = ZigLabel()
        modelLabel.font = NSFont(PingFangSemiBold: 20)
        contentView.addSubview(modelLabel)
        modelLabel.textColor = .white
        modelLabel.stringValue = modelName
        modelLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView).offset(10)
            make.top.equalTo(imageView.snp.bottom).offset((Self.padding + Self.bottomHeight) / 5)
        }
        
        let timeLabel = ZigLabel()
        modelLabel.font = NSFont(PingFang: 18)
        contentView.addSubview(timeLabel)
        timeLabel.textColor = .white
        timeLabel.stringValue = cTime
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView).offset(10)
            make.bottom.equalTo(contentView).offset(-(Self.padding + Self.bottomHeight) / 5)
        }
        
        let paramsLabel = ZigLabel()
        paramsLabel.font = NSFont(PingFang: 18)
        paramsLabel.alignment = .left
        contentView.addSubview(paramsLabel)
        paramsLabel.textColor = .white
        paramsLabel.stringValue = "\(exposureTime) \(fNumber) \(focalLength)"
        paramsLabel.snp.makeConstraints { make in
            make.trailing.equalTo(imageView).offset(-10)
            make.centerY.equalTo(modelLabel)
        }
        
        let lenModelLabel = ZigLabel()
        lenModelLabel.alignment = .left
        lenModelLabel.font = NSFont(PingFang: 18)
        contentView.addSubview(lenModelLabel)
        lenModelLabel.textColor = .white
        lenModelLabel.stringValue = lensModel
        lenModelLabel.snp.makeConstraints { make in
            make.trailing.equalTo(paramsLabel)
            make.leading.equalTo(paramsLabel)
            make.centerY.equalTo(timeLabel)
        }
        
        let sepLine = NSView()
        sepLine.wantsLayer = true
        sepLine.layer?.backgroundColor = NSColor.lightGray.cgColor
        contentView.addSubview(sepLine)
        sepLine.snp.makeConstraints { make in
            make.trailing.equalTo(paramsLabel.snp.leading).offset(-10)
            make.top.equalTo(paramsLabel).offset(-2)
            make.bottom.equalTo(lenModelLabel).offset(2)
            make.width.equalTo(2)
        }
        
        for screen in NSScreen.screens {
            if screen == NSScreen.main {
                print("\(screen.localizedName) 是当前显示器")
            } 
            let bounds = screen.frame
            print("屏幕 \(screen.localizedName) 的宽度: \(bounds.size.width), 高度: \(bounds.size.height)")
        }
    }
    
    override func loadWindow() {
        var width = 280.0, height = 400.0
        let standardHeight = 600.0, standardWidth = 600.0
        var minHeight = 400.0, minWidth = 400.0
        if let imageWidth = detailInfo?.imageMedia?.width, let imageHeight = detailInfo?.imageMedia?.height {
            let w_h_ration = Double(imageWidth) / Double(imageHeight)
            if imageWidth > imageHeight {
                width = standardWidth
                height = width / w_h_ration
                minHeight = minWidth / w_h_ration
            } else {
                height = standardHeight
                width = height * w_h_ration
                minWidth = minHeight * w_h_ration
            }
            
            let hasExif = (detailInfo?.imageMedia?.exifInfo?.isVaild ?? false)
            width += 2 * Self.padding
            height += (2 * Self.padding + (hasExif ? Self.bottomHeight : 0.0))
            minWidth += 2 * Self.padding
            minHeight += (2 * Self.padding + (hasExif ? Self.bottomHeight : 0.0))
        }
        let frame: CGRect = CGRect(x: 0, y: 0, width: width, height: height)
        let style: NSWindow.StyleMask = [.titled, .closable, .resizable, .fullSizeContentView]
        let back: NSWindow.BackingStoreType = .buffered
        let window: NSWindow = NSWindow(contentRect: frame, styleMask: style, backing: back, defer: false)
        window.minSize = CGSize(width: minWidth, height: minHeight)
        window.backgroundColor = NSColor.black
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.black.cgColor
        window.titlebarAppearsTransparent = true
        window.center()
        window.delegate = self
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        self.window = window
    }
}

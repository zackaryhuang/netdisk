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
    
    var detailInfo: AliFileDetail? {
        didSet {
            guard let info = detailInfo else { return }
            window?.animateToSize(getWindowSize(with: info))
            window?.minSize = getMinWindowSize(with: info)
            updateView(info)
        }
    }
    
    lazy var modelLabel = {
        let modelLabel = ZigLabel()
        modelLabel.font = NSFont(PingFangSemiBold: 20)
        modelLabel.textColor = .white
        return modelLabel
    }()
    
    lazy var timeLabel = {
        let timeLabel = ZigLabel()
        timeLabel.font = NSFont(PingFang: 18)
        timeLabel.textColor = .white
        return timeLabel
    }()
    
    lazy var paramsLabel = {
        let paramsLabel = ZigLabel()
        paramsLabel.font = NSFont(PingFang: 18)
        paramsLabel.textColor = .white
        return paramsLabel
    }()
    
    lazy var lenModelLabel = {
        let lenModelLabel = ZigLabel()
        lenModelLabel.alignment = .left
        lenModelLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        lenModelLabel.font = NSFont(PingFang: 18)
        lenModelLabel.textColor = .white
        lenModelLabel.lineBreakMode = .byTruncatingTail
        return lenModelLabel
    }()
    
    lazy var sepLine = {
        let sepLine = NSView()
        sepLine.wantsLayer = true
        sepLine.layer?.backgroundColor = NSColor.lightGray.cgColor
        return sepLine
    }()
    
    let imageView = {
        let view = ABImageView()
        view.contentMode = .aspectFit
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.backgroundColor = NSColor.black
        guard let info = detailInfo else { return }
        updateView(info)
    }
    
    func updateView(_ detailInfo: AliFileDetail) {
        guard let contentView = self.window?.contentView else { return }
        var bottom = Self.padding
        if (detailInfo.imageMedia?.exifInfo?.isValid ?? false) {
            bottom += Self.bottomHeight
        }
        
        if imageView.superview == nil {
            contentView.addSubview(imageView)
        }
        imageView.snp.remakeConstraints { make in
            make.edges.equalTo(contentView).inset(NSEdgeInsets(top: Self.padding, left: Self.padding, bottom: bottom, right: Self.padding))
        }
        
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
        imageView.kf.setImage(with: detailInfo.previewURL) { _ in
            guard let fileID = detailInfo.fileID else { return }
            
            Task {
                guard let downloadInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID),
                let downloadURL = downloadInfo.downloadURL else { return }
                self.imageView.kf.setImage(with: downloadURL, placeholder: self.imageView.image)
            }
        }
        
        let shouldShowParams = (detailInfo.imageMedia?.exifInfo?.isValid ?? false)
        [modelLabel, timeLabel, paramsLabel, lenModelLabel, sepLine].forEach { view in
            view.isHidden = !shouldShowParams
        }
        
        guard shouldShowParams,
              let exif = detailInfo.imageMedia?.exifInfo,
              let modelName = exif.Model?.value,
              let cTime = detailInfo.imageMedia?.time,
              let exposureTime = exif.ExposureTime?.value,
              let fNumber = exif.FNumber?.value,
              let focalLength = exif.FocalLength?.value,
              let iso = exif.ISOSpeedRatings?.value,
              let lensModel = exif.LensModel?.value else { return }
        
        if modelLabel.superview == nil {
            contentView.addSubview(modelLabel)
        }
        modelLabel.stringValue = modelName
        modelLabel.snp.remakeConstraints { make in
            make.leading.equalTo(imageView).offset(10)
            make.top.equalTo(imageView.snp.bottom).offset((Self.padding + Self.bottomHeight) / 5)
        }
        
        if timeLabel.superview == nil {
            contentView.addSubview(timeLabel)
        }
        timeLabel.stringValue = cTime
        timeLabel.snp.remakeConstraints { make in
            make.leading.equalTo(imageView).offset(10)
            make.bottom.equalTo(contentView).offset(-(Self.padding + Self.bottomHeight) / 5)
        }
        
        if paramsLabel.superview == nil {
            contentView.addSubview(paramsLabel)
        }
        paramsLabel.stringValue = "F\(fNumber) \(exposureTime)s \(iso)"
        paramsLabel.snp.remakeConstraints { make in
            make.trailing.equalTo(imageView).offset(-10)
            make.width.greaterThanOrEqualTo(200)
            make.centerY.equalTo(modelLabel)
        }
    
        if lenModelLabel.superview == nil {
            contentView.addSubview(lenModelLabel)
        }
        lenModelLabel.stringValue = lensModel
        lenModelLabel.snp.remakeConstraints { make in
            make.trailing.equalTo(paramsLabel)
            make.leading.equalTo(paramsLabel)
            make.centerY.equalTo(timeLabel)
        }
        
        if sepLine.superview == nil {
            contentView.addSubview(sepLine)
        }
        sepLine.snp.remakeConstraints { make in
            make.trailing.equalTo(paramsLabel.snp.leading).offset(-10)
            make.top.equalTo(paramsLabel).offset(-2)
            make.bottom.equalTo(lenModelLabel).offset(2)
            make.width.equalTo(2)
        }
    }
    
    private func getMinWindowSize(with detailInfo: AliFileDetail) -> CGSize {
        var minHeight = 400.0, minWidth = 400.0
        if let imageWidth = detailInfo.imageMedia?.width, let imageHeight = detailInfo.imageMedia?.height {
            let w_h_ration = Double(imageWidth) / Double(imageHeight)
            if imageWidth > imageHeight {
                minHeight = minWidth / w_h_ration
            } else {
                minWidth = minHeight * w_h_ration
            }
            
            let hasExif = (detailInfo.imageMedia?.exifInfo?.isValid ?? false)
            minWidth += 2 * Self.padding
            minHeight += (2 * Self.padding + (hasExif ? Self.bottomHeight : 0.0))
        }
        return CGSize(width: minWidth, height: minHeight)
    }
    
    private func getWindowSize(with detailInfo: AliFileDetail) -> CGSize {
        var width = 280.0, height = 400.0
        let standardHeight = 600.0, standardWidth = 600.0
        if let imageWidth = detailInfo.imageMedia?.width, let imageHeight = detailInfo.imageMedia?.height {
            let w_h_ration = Double(imageWidth) / Double(imageHeight)
            if imageWidth > imageHeight {
                width = standardWidth
                height = width / w_h_ration
            } else {
                height = standardHeight
                width = height * w_h_ration
            }
            
            let hasExif = (detailInfo.imageMedia?.exifInfo?.isValid ?? false)
            width += 2 * Self.padding
            height += (2 * Self.padding + (hasExif ? Self.bottomHeight : 0.0))
        }
        return CGSize(width: width, height: height)
    }
    
    override func loadWindow() {
        let windowSize = getWindowSize(with: detailInfo!)
        let minSize = getMinWindowSize(with: detailInfo!)
        let frame: CGRect = CGRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height)
        let style: NSWindow.StyleMask = [.titled, .closable, .resizable, .fullSizeContentView]
        let back: NSWindow.BackingStoreType = .buffered
        let window: NSWindow = NSWindow(contentRect: frame, styleMask: style, backing: back, defer: false)
        window.minSize = CGSize(width: minSize.width, height: minSize.height)
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

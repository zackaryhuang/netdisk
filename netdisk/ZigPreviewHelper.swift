//
//  ZigPreviewHelper.swift
//  netdisk
//
//  Created by Zackary on 2024/3/22.
//

import Foundation
import AppKit

class ZigPreviewHelper {
    static let shared = ZigPreviewHelper()
    var imagePreviewWindowController: ImagePreviewWindowController?
    public static func preview(fileData: FileData, driveID: String?) {
        switch fileData.category {
        case .Picture:
            debugPrint("预览照片")
            previewImageWith(fileID: fileData.fileID, driveID:driveID)
        case .Video:
            debugPrint("预览视频")
            previewVideoWith(fileID: fileData.fileID, driveID: driveID)
        case .Audio:
            debugPrint("预览音频")
        case .Document:
            debugPrint("预览文档")
        case .Application:
            debugPrint("预览应用")
        case .Torrent:
            debugPrint("预览种子")
        case .Others:
            debugPrint("预览其他")
        }
    }
    
    public static func previewImageWith(fileID: String, driveID: String?) {
        Task {
            guard let fileDetail = try? await WebRequest.requestFileDetail(fileID: fileID, driveID: driveID) else { return }
            await showImagePreviewController(detailInfo: fileDetail)
        }

    }
    
    @MainActor
    private static func showImagePreviewController(detailInfo: AliFileDetail) {
        var previewWindow = ZigPreviewHelper.shared.imagePreviewWindowController
        if previewWindow == nil {
            previewWindow = ImagePreviewWindowController()
            previewWindow!.detailInfo = detailInfo
            previewWindow!.window?.center()
        } else {
            previewWindow!.detailInfo = detailInfo
        }
        previewWindow!.window?.makeKeyAndOrderFront(nil)
        ZigPreviewHelper.shared.imagePreviewWindowController = previewWindow
    }
    
    public static func previewVideoWith(fileID: String, driveID: String?) {
        Task {
            if let fileInfo = try? await WebRequest.requestDownloadUrl(fileID: fileID, driveID: driveID),
               let url = fileInfo.downloadURL?.absoluteString.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed),
               let playURL = URL(string: "iina://weblink?url=\(url)"){
                // DownloadUrl 获取的链接为原画画质
                NSWorkspace.shared.open(playURL)
            } else if let playInfo = try? await WebRequest.requestVideoPlayInfo(fileID: fileID),
                      let url = playInfo.playURL?.absoluteString.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed),
                      let playURL = URL(string: "iina://weblink?url=\(url)"){
                // 通过 PlayInfo 获取的为转码后的画质中的最好的一档画质
                NSWorkspace.shared.open(playURL)
            }
        }
    }
}

//
//  VideoPreviewView.swift
//  VideoPreviewView
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct VideoPreviewViewRepresentable: UIViewRepresentable {
    @ObservedObject var setInfoModel: SetInfoModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        // Configure the preview layer
        let previewLayer = setInfoModel.frameExtractor.previewLayer
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        setInfoModel.frameExtractor.previewLayer.frame = uiView.bounds
    }
}

//
//  VideoPreviewView.swift
//  VideoPreviewView
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct VideoPreviewViewRepresentable: UIViewRepresentable {
    @ObservedObject var setInfoModel: SetInfoModel

    func makeUIView(context _: Context) -> UIView {
        let view = UIView(frame: .zero)

        // Verwijder de previewLayer van een eventuele vorige superlayer
        setInfoModel.frameExtractor.previewLayer.removeFromSuperlayer()

        // Configureer de previewLayer
        let previewLayer = setInfoModel.frameExtractor.previewLayer
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context _: Context) {
        DispatchQueue.main.async {
            self.setInfoModel.frameExtractor.previewLayer.frame = uiView.bounds
            self.setInfoModel.frameExtractor.previewLayer.setAffineTransform(CGAffineTransform.identity)
        }
    }
}

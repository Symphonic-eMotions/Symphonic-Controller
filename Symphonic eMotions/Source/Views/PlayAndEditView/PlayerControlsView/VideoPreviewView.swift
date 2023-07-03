//
//  VideoPreviewView.swift
//  VideoPreviewView
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct VideoPreviewViewRepresetable: UIViewRepresentable {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        try? setInfoModel.frameExtractor.displayPreview(on: view)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        if setInfoModel.setInfoState.displayMode == .video || setInfoModel.setInfoState.displayMode == .both {
                try? setInfoModel.frameExtractor.displayPreview(on: uiView)
        }
        else if setInfoModel.setInfoState.displayMode == .refresh {
            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            try? setInfoModel.frameExtractor.displayPreview(on: view)
            
            setInfoModel.setInfoState.displayMode = .both
        }
        else {
            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            try? setInfoModel.frameExtractor.displayPreview(on: view)
        }
    }
    
}

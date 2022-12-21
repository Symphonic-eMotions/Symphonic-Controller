//
//  VideoPreviewView.swift
//  VideoPreviewView
//
//  Created by Mihai Fratu on 31.07.2021.
//

import SwiftUI

struct VideoPreviewViewRepresetable: UIViewRepresentable {
    
    @ObservedObject var playViewModel: PlayViewModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        try? playViewModel.frameExtractor.displayPreview(on: view)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        if playViewModel.playViewState.displayMode == .video || playViewModel.playViewState.displayMode == .both {
            
            try? playViewModel.frameExtractor.displayPreview(on: uiView)
        }
        else if playViewModel.playViewState.displayMode == .refresh {
            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            try? playViewModel.frameExtractor.displayPreview(on: view)
            
            playViewModel.playViewState.displayMode = .both
        }
        else {
            let view = UIView(frame: UIScreen.main.bounds)
            view.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            try? playViewModel.frameExtractor.displayPreview(on: view)
        }
    }
    
}

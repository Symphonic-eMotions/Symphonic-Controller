//
//  BinaryFileSelectionView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct BinaryFileSelectionView: View {
    @State private var selectedFile: URL?
    
    var body: some View {
        VStack {
            if selectedFile != nil {
                Text("Selected file: \(selectedFile!.lastPathComponent)")
                    .padding()
            }
            
            Button("Select File") {
                let types = [UTType.data]
                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: types)
                let delegate = BinaryFileSelectionDelegate(selectedFile: $selectedFile)
                documentPicker.delegate = delegate
                UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
}

class BinaryFileSelectionDelegate: NSObject, UIDocumentPickerDelegate {
    @Binding var selectedFile: URL?
    
    init(selectedFile: Binding<URL?>) {
        _selectedFile = selectedFile
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        
        selectedFile = selectedFileURL
        
        // Move the selected file to the app's Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsDirectory.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        do {
            try FileManager.default.moveItem(at: selectedFileURL, to: destinationURL)
            print("File moved to documents directory")
        } catch {
            print("Error moving file: \(error)")
        }
    }
}


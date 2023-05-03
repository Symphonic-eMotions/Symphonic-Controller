//
//  FilePickerView.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 14/03/2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct FilePickerView: View {
    @State private var selectedFile: URL?
    
    var body: some View {
        VStack {
            if selectedFile != nil {
                Text("Selected file: \(selectedFile!.lastPathComponent)")
                    .padding()
            }
            
            Button("Select File") {
//                let types = ["public.audio", "public.midi-audio"]
                let types = [UTType.data]
                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: types)
                let delegate = FilePickerDelegate(selectedFile: $selectedFile)
                documentPicker.delegate = delegate
                
                // Find the first window scene
                guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                    return
                }
                
                // Find the key window in the scene
                guard let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                    return
                }
                
                keyWindow.rootViewController?.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
}

class FilePickerDelegate: NSObject, UIDocumentPickerDelegate {
    
    @Binding var selectedFile: URL?
    
    init(selectedFile: Binding<URL?>) {
        _selectedFile = selectedFile
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //
        
        for url in urls {
            
            // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                return
            }
            
            do {
                let _ = try Data.init(contentsOf: url)
                
                // You will have data of the selected file
            }
            catch {
                print(error.localizedDescription)
            }
            
            // Make sure you release the security-scoped resource when you finish.
            do { url.stopAccessingSecurityScopedResource() }
        }
        
        //        guard let selectedFileURL = urls.first else {
        //            return
        //        }
        
        
        
        //        // Move the selected file to the app's Documents directory
        //        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //        let destinationURL = documentsDirectory.appendingPathComponent(selectedFileURL.lastPathComponent)
        //
        //        do {
        //            try FileManager.default.moveItem(at: selectedFileURL, to: destinationURL)
        //            print("File moved to documents directory")
        //        } catch {
        //            print("Error moving file: \(error)")
        //        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

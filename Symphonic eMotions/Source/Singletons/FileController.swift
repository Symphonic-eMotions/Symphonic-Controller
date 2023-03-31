//
//  FileController.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 26/10/2022.
//

import Foundation
import OrderedCollections

struct SeMFile {
    
    var name: String
    var location: URL
    var grouped: String
    var owner: String
}

class FileController: ObservableObject {
    
    private let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    public var loadedURL: [URL] = []
    
    func addDirectoryURLsToController() -> [URL]{
        
        self.loadedURL = getContentsOfDirectory()
        
        return self.loadedURL
    }
    
    func addSetFileURLToController(fileName: String) {
        
        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = directoryURL.appendingPathComponent(fileName)
        loadedURL.append(fileURL)
    }
    
    func getContentsOfDirectory() -> [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(at: self.directoryURL, includingPropertiesForKeys: nil)
        } catch {
            print(error)
            return []
        }
    }
        
    func urlToNameParts( url: URL) -> [String] {
        var nameParts: [String] = []
        let noExt = url.deletingPathExtension()
        let file = noExt.lastPathComponent
        nameParts = file.components(separatedBy: "-timestamp-")
        return nameParts
    }
    
    func fileContents( url: URL, fileName: String ) -> String {
        
        var fileNameReturn = fileName
        
        if let instrumentSet = InstrumentsSet.withFileManagerJSON(urlToFileName(url: url)) {
            
            if isCustomNameNotEmpty(set: instrumentSet){
                fileNameReturn = instrumentSet.customName
            }
        }
        return fileNameReturn
    }
    
    func isCustomNameNotEmpty(set: InstrumentsSet) -> Bool {
        
        return set.customName != ""
    }
    
    func urlToFileName( url: URL) -> String{
        return url.lastPathComponent
    }
    
    func isURLInGroup( url: URL, name: String ) -> Bool {
        let nameParts = urlToNameParts(url: url)
        if nameParts.first! == name {
            return true
        }
        return false
    }
    
    func date(url: URL) -> String{
        let nameParts = urlToNameParts(url: url)
        if nameParts.count > 1 {
            let date = Date(timeIntervalSince1970: Double(nameParts.last!)!)
            let format = date.getFormattedDate(format: "dd-MM-yyyy HH:mm")
            return format
        }
        return nameParts.first ?? "No name"
    }
    
    func name(url: URL) -> String{
        let nameParts = urlToNameParts(url: url)
        if nameParts.count > 1 {
            return nameParts.first!
        }
        return "Mismatch"
    }
}

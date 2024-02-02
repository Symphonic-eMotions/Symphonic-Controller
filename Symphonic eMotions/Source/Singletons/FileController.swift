//
//  FileController.swift
//  Symphonic eMotions Intern
//
//  Created by Frans-Jan Wind on 26/10/2022.
//

import Foundation
import OrderedCollections
import SwiftUI

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
    
    public func addSetFileURLToController(fileName: String) {
        
        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = directoryURL.appendingPathComponent(fileName)
        loadedURL.append(fileURL)
    }
    
    public func getContentsOfDirectory() -> [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(at: self.directoryURL, includingPropertiesForKeys: nil)
        } catch {
            print(error)
            return []
        }
    }
        
    private func urlToNameParts( url: URL) -> [String] {
        var nameParts: [String] = []
        let noExt = url.deletingPathExtension()
        let file = noExt.lastPathComponent
        nameParts = file.components(separatedBy: "-timestamp-")
        return nameParts
    }
    
    public func fileNameOrCustomName( url: URL, fileName: String ) -> String {
        
        var fileNameReturn = fileName
        
        if let instrumentSet = InstrumentsSet.withOnlineJSON(url) {
            
            if isCustomNameNotEmpty(set: instrumentSet){
                fileNameReturn = instrumentSet.customName
            }
        }
        return fileNameReturn
    }
    
    public func setNameCustomName( url: URL ) -> String {
     
        guard let instrumentSet: InstrumentsSet = AppUtils.loadURLServerInstrumentSet(urlServer: url.absoluteString) else {
            return "Set not loaded error"
        }
        
        if instrumentSet.customName != "" {
            return instrumentSet.customName
        }
        else{
            return instrumentSet.name
        }
    }
    
    public func getSmootherVersion(url:URL) -> Int {
        guard let instrumentSet: InstrumentsSet = AppUtils.loadURLServerInstrumentSet(urlServer: url.absoluteString) else {
            return 0
        }
        
        print("---------------->>>>>>>>>>>>> FILECONTROLLER \(instrumentSet.smootherVersion)")
        
        return instrumentSet.smootherVersion
    }
    
    public func fileContents(url: URL) -> InstrumentsSet? {
        if let instrumentSet = InstrumentsSet.withFileManagerJSON(urlToFileName(url: url)) {
                return instrumentSet
        }
        return nil
    }
    
    private func isCustomNameNotEmpty(set: InstrumentsSet) -> Bool {
        
        return set.customName != ""
    }
    
    public func urlToFileName( url: URL) -> String{
        return url.lastPathComponent
    }
    public func urlToPlayListFileName( url: URL) -> String{
        return url.lastTwoPathComponents
    }
    
    public func isURLInGroup( url: URL, name: String ) -> Bool {
        
        let nameParts = urlToNameParts(url: url)
        //Name is in file but not a folder with this name
        if nameParts.first! == name && nameParts.count > 1 {
            return true
        }
        return false
    }
    
    public func date(url: URL) -> String {
        let nameParts = urlToNameParts(url: url)
        if nameParts.count > 1 {
            let timestamp = Double(nameParts.last!)!
            let date = Date(timeIntervalSince1970: timestamp)
            
            // Create a RelativeDateTimeFormatter instance
            let formatter = RelativeDateTimeFormatter()
            
            // Set the locale to the system locale to use the user's preferred language
            formatter.locale = .current
            
            // Format the date relative to the current date
            let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
            
            // Append the time with seconds
            let timeFormat = DateFormatter.dateFormat(fromTemplate: "jm", options: 0, locale: Locale.current)!
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = timeFormat
            let time = timeFormatter.string(from: date)
            return "\(relativeDate) at \(time)"
        }
        return nameParts.first ?? "No name"
    }
    
    public func nameFromUrl(url: URL) -> String{
        let nameParts = urlToNameParts(url: url)
        if nameParts.count > 1 {
            return nameParts.first!
        }
        return "Mismatch \(url.lastPathComponent)"
    }
    
    public func deleteFile(url: URL) -> [URL] {
        do {
            try FileManager.default.removeItem(at: url)

        } catch {
            print("Error deleting file: \(error)")
        }
        
        return self.getContentsOfDirectory()
    }
}

extension URL {
    var lastTwoPathComponents: String {
        let parentDirectoryName = self.deletingLastPathComponent().lastPathComponent
        let fileName = self.lastPathComponent
        return "\(parentDirectoryName)/\(fileName)"
    }
}

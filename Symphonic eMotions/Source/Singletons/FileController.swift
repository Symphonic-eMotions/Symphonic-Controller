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
    
    public func fileContents( url: URL, fileName: String ) -> String {
        
        var fileNameReturn = fileName
        
        if let instrumentSet = InstrumentsSet.withFileManagerJSON(urlToFileName(url: url)) {
            
            if isCustomNameNotEmpty(set: instrumentSet){
                fileNameReturn = instrumentSet.customName
            }
        }
        return fileNameReturn
    }
    
    private func isCustomNameNotEmpty(set: InstrumentsSet) -> Bool {
        
        return set.customName != ""
    }
    
    public func urlToFileName( url: URL) -> String{
        return url.lastPathComponent
    }
    
    public func isURLInGroup( url: URL, name: String ) -> Bool {
        let nameParts = urlToNameParts(url: url)
        if nameParts.first! == name {
            return true
        }
        return false
    }
    
//    public func date(url: URL) -> String{
//        let nameParts = urlToNameParts(url: url)
//        if nameParts.count > 1 {
//            let date = Date(timeIntervalSince1970: Double(nameParts.last!)!)
//            let format = date.getFormattedDate(format: "dd-MM-yyyy HH:mm")
//            return format
//        }
//        return nameParts.first ?? "No name"
//    }
    
//    public func date(url: URL) -> String {
//        let nameParts = urlToNameParts(url: url)
//        if nameParts.count > 1 {
//            let timestamp = Double(nameParts.last!)!
//            let date = Date(timeIntervalSince1970: timestamp)
//
//            // Create a RelativeDateTimeFormatter instance
//            let formatter = RelativeDateTimeFormatter()
//
//            // Set the locale to the system locale to use the user's preferred language
//            formatter.locale = .current
//
//            // Format the date relative to the current date
//            let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
//
//            // Append the time
//            let timeFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
//            let timeFormatter = DateFormatter()
//            timeFormatter.dateFormat = timeFormat
//            let time = timeFormatter.string(from: date)
//            return "\(relativeDate) at \(time)"
//        }
//        return nameParts.first ?? "No name"
//    }
    
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
    
    public func name(url: URL) -> String{
        let nameParts = urlToNameParts(url: url)
        if nameParts.count > 1 {
            return nameParts.first!
        }
        return "Mismatch"
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

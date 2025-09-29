//
//  FileLogger.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 22/10/2023.
//

import Foundation

class FileLogger {
    private var fileHandle: FileHandle?
    private let logFilePath: String

    init(fileName: String = "SeM-debug.log") {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: logFilePath) {
            FileManager.default.createFile(atPath: logFilePath, contents: nil, attributes: nil)
        }

        fileHandle = FileHandle(forWritingAtPath: logFilePath)
    }

    deinit {
        fileHandle?.closeFile()
    }

    func log(_ message: String) {
        guard let fileHandle = fileHandle else {
            print("Error accessing file handle.")
            return
        }

        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .long)
        let logString = "[\(timestamp)]: \(message)\n"

        if let data = logString.data(using: .utf8) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
    }
}

//
//  FileCache.swift
//  Symphonic eMotions Pro
//
//  Created by Frans-Jan Wind on 31/01/2024.
//

import Foundation

class FileCache {
    
    private var cache: [String: [SetFile]] = [:]
    private let queue = DispatchQueue(label: "nl.symphonic-emotions.fileCacheQueue")
    private var setFiles: [SetFile]

    init(setFiles: [SetFile]) {
        self.setFiles = setFiles
    }
    
    func getSetFiles(for group: FileGroup, with compareView: SessionDisplay) -> [SetFile] {
        let cacheKey = "\(group.hashValue)-\(compareView.hashValue)"
        return queue.sync {
            if let cachedFiles = cache[cacheKey] {
                return cachedFiles
            } else {
                let files = fetchSetFiles(for: group, with: compareView)
                cache[cacheKey] = files
                return files
            }
        }
    }
    
    func invalidateCache(for group: FileGroup? = nil, with compareView: SessionDisplay? = nil) {
        queue.async {
            if let group = group, let compareView = compareView {
                let cacheKey = "\(group.hashValue)-\(compareView.hashValue)"
                self.cache.removeValue(forKey: cacheKey)
            } else {
                self.cache.removeAll()
            }
        }
    }
    
    private func fetchSetFiles(for group: FileGroup, with compareView: SessionDisplay) -> [SetFile] {

        return setFiles.filter { setFile in
            
            // Check if the file belongs to the specified group
            let isPartOfGroup = setFile.fileGroup == group

            // Check if the file is published
            let isPublished = setFile.published
            
            // Return true if both conditions are met
            return ( isPartOfGroup && isPublished )
        }
    }
}

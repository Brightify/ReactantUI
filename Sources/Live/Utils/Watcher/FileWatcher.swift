//
//  FileWatcher.swift
//  ReactantLiveUI
//
//  Created by Filip Dolnik on 13.06.18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation
import RxSwift

class FileWatcher: Watcher {

    struct Error: Swift.Error {
        public let message: String
    }
    
    private let subject = ReplaySubject<(String, Data)>.create(bufferSize: 1)
    private let path: String
    private let queue: DispatchQueue
    private let events: DispatchSource.FileSystemEvent
    
    private var source: DispatchSourceFileSystemObject?
    
    private(set) var fileContent = Data()
    
    init(path: String, events: DispatchSource.FileSystemEvent = .all, queue: DispatchQueue = DispatchQueue.main) throws {
        self.path = path
        self.events = events
        self.queue = queue
        
        try setup()
    }
    
    private func setup() throws {
        let path = self.path
        let handle = open(path , O_EVTONLY)
        guard handle != -1 else {
            throw Error(message: "Watcher: Failed to open file \(path)")
        }
        
        reloadFile()
        
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: handle, eventMask: events, queue: queue)
        source.setEventHandler { [weak source, weak self] in
            if let source = source, source.data.contains(.delete) || source.data.contains(.rename) {
                source.cancel()
                self?.source = nil
                _ = try? self?.setup()
            }
            self?.reloadFile()
        }
        
        source.setCancelHandler {
            close(handle)
        }
        
        self.source = source
        
        source.resume()
    }
    
    func watch() -> Observable<(String, Data)> {
        return subject
    }
    
    deinit {
        source?.cancel()
        subject.onCompleted()
    }
    
    private func reloadFile() {
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url, options: .uncached) else {
            print("ERROR: file \(path) not found")
            return
        }
        
        fileContent = data
        subject.onNext((path, data))
    }
}

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
    
    private var watchedFiles: [String: (source: DispatchSourceFileSystemObject?, subject: ReplaySubject<(file: String, data: Data)>)] = [:]
    
    deinit {
        for file in watchedFiles {
            file.value.source?.cancel()
            file.value.subject.onCompleted()
        }
    }
    
    func watch(file: String) -> Observable<(file: String, data: Data)> {
        if watchedFiles[file] == nil {
            watchedFiles[file] = (nil, ReplaySubject.create(bufferSize: 1))
            reload(file: file)
            setupFileObserver(file: file)
        }
        
        return watchedFiles[file]?.subject.asObservable() ?? Observable.never()
    }
    
    func stopWatching(file: String) {
        watchedFiles[file]?.source?.cancel()
        watchedFiles[file]?.subject.onCompleted()
        watchedFiles.removeValue(forKey: file)
    }
    
    func preload(rootDir: String) {
    }
    
    func reloadAll(in rootDir: String) -> [(file: String, data: Data)] {
        guard let enumerator = FileManager.default.enumerator(atPath: rootDir) else { return [] }
        
        return enumerator
            .compactMap { $0 as? String }
            .filter { $0.hasSuffix(".ui.xml") }
            .compactMap {
                let path = rootDir + "/" + $0
                let url = URL(fileURLWithPath: path)
                if let data = try? Data(contentsOf: url, options: .uncached) {
                    return (path, data)
                } else {
                    return nil
                }
        }
    }
    
    private func reload(file: String) {
        let url = URL(fileURLWithPath: file)
        guard let data = try? Data(contentsOf: url, options: .uncached) else {
            print("ERROR: file \(file) not found")
            return
        }
        watchedFiles[file]?.subject.onNext((file, data))
    }
    
    private func setupFileObserver(file: String) {
        guard watchedFiles[file]?.source == nil else { return }
        
        let handle = open(file , O_EVTONLY)
        guard handle != -1 else {
            print("Error: Watcher: Failed to open file \(file)")
            return
        }
        
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: handle, eventMask: [.delete, .write, .rename], queue: DispatchQueue.main)
        watchedFiles[file]?.source = source
        
        source.setEventHandler { [weak source, weak self] in
            if let source = source, source.data.contains(.delete) || source.data.contains(.rename) {
                source.cancel()
                self?.watchedFiles[file]?.source = nil
                self?.setupFileObserver(file: file)
            }
            self?.reload(file: file)
        }
        source.setCancelHandler {
            close(handle)
        }
        source.resume()
    }
}

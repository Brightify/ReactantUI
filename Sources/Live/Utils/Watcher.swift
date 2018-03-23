//
//  Watcher.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
import RxSwift

/// Watches for file changes inside a specific path and sends an event through `subject` containing the path of changed file.
public class Watcher {
    public struct Error: Swift.Error {
        public let message: String
    }

    private let subject = PublishSubject<String>()
    private let path: String
    private let queue: DispatchQueue
    private let events: DispatchSource.FileSystemEvent

    private var source: DispatchSourceFileSystemObject?

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

        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: handle, eventMask: events, queue: queue)
        source.setEventHandler { [subject, weak source, weak self] in
            if let source = source, source.data.contains(.delete) || source.data.contains(.rename) {
                source.cancel()
                self?.source = nil
                _ = try? self?.setup()
            }
            subject.onNext(path)
        }

        source.setCancelHandler {
            close(handle)
        }

        self.source = source

        source.resume()
    }

    func watch() -> Observable<String> {
        return subject
    }

    deinit {
        source?.cancel()
        subject.onCompleted()
    }
}

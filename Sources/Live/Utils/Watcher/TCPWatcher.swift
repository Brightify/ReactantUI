//
//  TCPWatcher.swift
//  ReactantUI
//
//  Created by Filip Dolnik on 13.06.18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation
import RxSwift

class TCPWatcher: Watcher {

    let path: String
    
    private var client: TCPWatcherClient
    private let subject = ReplaySubject<(String, Data)>.create(bufferSize: 1)
    
    private var hasData = false
    private let condition = NSCondition()
    
    private(set) var fileContent = Data()
    
    init(path: String, client: TCPWatcherClient) {
        self.path = path
        self.client = client
        
        client.register(watcher: self) { [weak self] in
            self?.fileContent = $1
            self?.subject.onNext(($0, $1))
            
            self?.condition.lock()
            self?.hasData = true
            self?.condition.unlock()
            self?.condition.signal()
        }
        
        condition.lock()
        if !hasData {
            condition.wait(until: Date().addingTimeInterval(0.5))
        }
        condition.unlock()
    }
    
    init(path: String, data: Data, client: TCPWatcherClient) {
        self.path = path
        self.client = client
        
        subject.onNext((path, data))
        hasData = true
        
        client.register(watcher: self) { [weak self] in
            self?.fileContent = $1
            self?.subject.onNext(($0, $1))
        }
    }
    
    func watch() -> Observable<(String, Data)> {
        return subject.observeOn(MainScheduler.instance)
    }
    
    deinit {
        client.unregister(watcher: self)
        subject.onCompleted()
    }
}

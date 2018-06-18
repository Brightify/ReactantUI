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
    
    private(set) var fileContent = Data()
    
    init(path: String, client: TCPWatcherClient) {
        self.path = path
        self.client = client
        
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

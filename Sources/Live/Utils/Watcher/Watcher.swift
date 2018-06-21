//
//  Watcher.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
import RxSwift

/// Watches for XML files changes and sends an event through `subject` containing the path and content of changed file.
protocol Watcher {
    
    func watch(file: String) -> Observable<(file: String, data: Data)>
    
    func stopWatching(file: String)
    
    func preload(rootDir: String)
    
    func reloadAll(in rootDir: String) -> [(file: String, data: Data)]
}

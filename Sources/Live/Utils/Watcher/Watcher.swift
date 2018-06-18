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
protocol Watcher {
    
    var fileContent: Data { get }
    
    func watch() -> Observable<(String, Data)>
}

//
//  LiveHyperViewBase.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 07/06/2019.
//

import UIKit
import Hyperdrive

open class LiveHyperViewBase: HyperViewBase {
    internal let xmlPath: String
    internal let typeName: String
    internal let worker: ReactantLiveUIWorker

    public init(worker: ReactantLiveUIWorker, typeName: String, xmlPath: String) {
        self.typeName = typeName
        self.xmlPath = xmlPath
        self.worker = worker

        super.init()

        worker.register(self, setConstraint: { name, constraint in
            return false
        })
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        worker.reapply(self)
    }

    deinit {
        worker.unregister(self)
    }
}

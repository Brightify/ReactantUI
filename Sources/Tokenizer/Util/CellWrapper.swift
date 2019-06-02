//
//  CellWrapper.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation
#if canImport(UIKit)
    import UIKit
    import Hyperdrive
    import RxDataSources
    
public final class CellWrapper: HyperViewBase, HyperView {
        public static let triggerReloadPaths: Set<String> = []

        public typealias State = EmptyState
        public typealias Action = Void

        private let wrapped: UIView

        public let state: State

        public init(initialState: State = State(), actionPublisher: ActionPublisher<Action>) {
            state = initialState
            wrapped = UIView()

            super.init()

            loadView()
            setupConstraints()
        }

        public init(wrapped: UIView) {
            self.wrapped = wrapped
            self.state = State()

            super.init()

            loadView()
            setupConstraints()
        }

        private func loadView() {
            [
                wrapped
            ].forEach(addSubview(_:))
        }

        private func setupConstraints() {
            wrapped.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
#endif

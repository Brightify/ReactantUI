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
    
    public final class CellWrapper: ViewBase<Void, Void> {
        private let wrapped: UIView

        public init(wrapped: UIView) {
            self.wrapped = wrapped
            super.init(initialState: ())
        }

        public override func loadView() {
            [
                wrapped
            ].forEach(addSubview(_:))
        }

        public override func setupConstraints() {
            wrapped.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
#endif

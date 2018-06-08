//
//  CellWrapper.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation
#if canImport(UIKit)
    import UIKit
    import Reactant
    import RxDataSources
    
    public final class CellWrapper: ViewBase<Void, Void> {
        private let wrapped: UIView

        public init(wrapped: UIView) {
            self.wrapped = wrapped
            super.init()
        }

        public override func loadView() {
            children(
                wrapped
            )
        }

        public override func setupConstraints() {
            wrapped.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
#endif

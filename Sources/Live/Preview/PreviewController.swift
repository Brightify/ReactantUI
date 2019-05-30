//
//  PreviewController.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Hyperdrive
import RxSwift

final class PreviewController: HyperViewController<PreviewRootView> {
    struct Parameters {
        let typeName: String
        let view: UIView
    }

    private let parameters: Parameters

    private let closeButton = UIBarButtonItem(title: "Close", style: .done, target: nil, action: nil)
    private let lifetimeDisposeBag = DisposeBag()

    init(parameters: Parameters) {
        self.parameters = parameters

        super.init()

        afterInit()
    }

    private func afterInit() {
        navigationItem.leftBarButtonItem = closeButton
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true) { }
            })
            .disposed(by: lifetimeDisposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if os(iOS)
        navigationController?.hidesBarsOnTap = true
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if os(iOS)
        navigationController?.hidesBarsOnTap = false
        #endif
    }
}

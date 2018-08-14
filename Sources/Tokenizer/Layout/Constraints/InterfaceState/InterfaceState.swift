//
//  InterfaceState.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 03/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation
// canImport(Common) is required because there's no module "Common" in ReactantLiveUI
#if canImport(Common)
import Common
#endif

/**
 * Structure containing information about the current interface.
 */
public struct InterfaceState {
    public let interfaceIdiom: InterfaceIdiom
    public let horizontalSizeClass: InterfaceSizeClass
    public let verticalSizeClass: InterfaceSizeClass
    public let viewOrientation: ViewOrientation
    public let rootDimensions: (width: Float, height: Float)

    public init(interfaceIdiom: InterfaceIdiom,
                horizontalSizeClass: InterfaceSizeClass,
                verticalSizeClass: InterfaceSizeClass,
                rootDimensions: (width: Float, height: Float)) {

        self.interfaceIdiom = interfaceIdiom
        self.horizontalSizeClass = horizontalSizeClass
        self.verticalSizeClass = verticalSizeClass
        self.rootDimensions = rootDimensions
        self.viewOrientation = ViewOrientation(width: rootDimensions.width, height: rootDimensions.height)
    }
}

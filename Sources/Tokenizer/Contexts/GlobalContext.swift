//
//  GlobalContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

public struct GlobalContext: DataContext {
    public let styleSheets: [String]
//    public let fonts: [String]
//    public let colors: [UIColor]

    public init(styleSheets: [String]) {
        self.styleSheets = styleSheets
    }
}

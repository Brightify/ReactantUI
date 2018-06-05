//
//  ParagraphStyleProperties.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2018.
//

import Foundation

public class ParagraphStyleProperties: PropertyContainer {
    public let alignment: AssignablePropertyDescription<TextAlignment>
    public let firstLineHeadIndent: AssignablePropertyDescription<Float>
    public let headIndent: AssignablePropertyDescription<Float>
    public let tailIndent: AssignablePropertyDescription<Float>
    public let tabStops: AssignablePropertyDescription<[TextTab]>
    public let lineBreakMode: AssignablePropertyDescription<LineBreakMode>
    public let maximumLineHeight: AssignablePropertyDescription<Float>
    public let minimumLineHeight: AssignablePropertyDescription<Float>
    public let lineHeightMultiple: AssignablePropertyDescription<Float>
    public let lineSpacing: AssignablePropertyDescription<Float>
    public let paragraphSpacing: AssignablePropertyDescription<Float>
    public let paragraphSpacingBefore: AssignablePropertyDescription<Float>

    public required init(configuration: Configuration) {
        alignment = configuration.property(name: "alignment")
        firstLineHeadIndent = configuration.property(name: "firstLineHeadIndent")
        headIndent = configuration.property(name: "headIndent")
        tailIndent = configuration.property(name: "tailIndent")
        tabStops = configuration.property(name: "tabStops")
        lineBreakMode = configuration.property(name: "lineBreakMode")
        maximumLineHeight = configuration.property(name: "maximumLineHeight")
        minimumLineHeight = configuration.property(name: "minimumLineHeight")
        lineHeightMultiple = configuration.property(name: "lineHeightMultiple")
        lineSpacing = configuration.property(name: "lineSpacing")
        paragraphSpacing = configuration.property(name: "paragraphSpacing")
        paragraphSpacingBefore = configuration.property(name: "paragraphSpacingBefore")

        super.init(configuration: configuration)
    }
}

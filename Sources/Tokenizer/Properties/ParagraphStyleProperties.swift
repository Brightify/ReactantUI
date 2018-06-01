//
//  ParagraphStyleProperties.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2018.
//

import Foundation

// IMPORTANT
// A paragraph style object should not be mutated after adding it to an attributed string; doing so can cause the app to crash.
public class ParagraphStyleProperties: PropertyContainer {
    public let alignment: AssignablePropertyDescription<TextAlignment>
    public let firstLineHeadIndent: AssignablePropertyDescription<Float>
    public let headIndent: AssignablePropertyDescription<Float>
    public let tailIndent: AssignablePropertyDescription<Float>
    public let tabStops: AssignablePropertyDescription<[Int]>
    public let defaultTabInterval: AssignablePropertyDescription<Float>
    public let lineBreakMode: AssignablePropertyDescription<LineBreakMode> // this might need its own type instead
    public let maximumLineHeight: AssignablePropertyDescription<Float>
    public let minimumLineHeight: AssignablePropertyDescription<Float>
    public let lineHeightMultiple: AssignablePropertyDescription<Float>
    public let lineSpacing: AssignablePropertyDescription<Float>
    public let paragraphSpacing: AssignablePropertyDescription<Float>
    public let paragraphSpacingBefore: AssignablePropertyDescription<Float>
    public let hyphenationFactor: AssignablePropertyDescription<Float>
    public let allowsDefaultTighteningForTruncation: AssignablePropertyDescription<Bool>

    public required init(configuration: Configuration) {
        alignment = configuration.property(name: "alignment")
        firstLineHeadIndent = configuration.property(name: "firstLineHeadIndent")
        headIndent = configuration.property(name: "headIndent")
        tailIndent = configuration.property(name: "tailIndent")
        tabStops = configuration.property(name: "tabStops")
        defaultTabInterval = configuration.property(name: "defaultTabInterval")
        lineBreakMode = configuration.property(name: "lineBreakMode")
        maximumLineHeight = configuration.property(name: "maximumLineHeight")
        minimumLineHeight = configuration.property(name: "minimumLineHeight")
        lineHeightMultiple = configuration.property(name: "lineHeightMultiple")
        lineSpacing = configuration.property(name: "lineSpacing")
        paragraphSpacing = configuration.property(name: "paragraphSpacing")
        paragraphSpacingBefore = configuration.property(name: "paragraphSpacingBefore")
        hyphenationFactor = configuration.property(name: "hyphenationFactor")
        allowsDefaultTighteningForTruncation = configuration.property(name: "allowsDefaultTighteningForTruncation")

        super.init(configuration: configuration)
    }
}

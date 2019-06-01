//
//  ParagraphStyleProperties.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2018.
//

import Foundation

public class ParagraphStyleProperties: PropertyContainer {
    public let alignment: AssignablePropertyDescription<TextAlignment>
    public let firstLineHeadIndent: AssignablePropertyDescription<Double>
    public let headIndent: AssignablePropertyDescription<Double>
    public let tailIndent: AssignablePropertyDescription<Double>
    public let tabStops: AssignablePropertyDescription<[TextTab]>
    public let lineBreakMode: AssignablePropertyDescription<LineBreakMode>
    public let maximumLineHeight: AssignablePropertyDescription<Double>
    public let minimumLineHeight: AssignablePropertyDescription<Double>
    public let lineHeightMultiple: AssignablePropertyDescription<Double>
    public let lineSpacing: AssignablePropertyDescription<Double>
    public let paragraphSpacing: AssignablePropertyDescription<Double>
    public let paragraphSpacingBefore: AssignablePropertyDescription<Double>

    public required init(configuration: Configuration) {
        let defaultTabStops = (1...12).map { i in
            TextTab(textAlignment: .left, location: Double(28 * i))
        }

        alignment = configuration.property(name: "alignment", defaultValue: .natural)
        firstLineHeadIndent = configuration.property(name: "firstLineHeadIndent")
        headIndent = configuration.property(name: "headIndent")
        tailIndent = configuration.property(name: "tailIndent")
        tabStops = configuration.property(name: "tabStops", defaultValue: defaultTabStops)
        lineBreakMode = configuration.property(name: "lineBreakMode", defaultValue: .byWordWrapping)
        maximumLineHeight = configuration.property(name: "maximumLineHeight")
        minimumLineHeight = configuration.property(name: "minimumLineHeight")
        lineHeightMultiple = configuration.property(name: "lineHeightMultiple")
        lineSpacing = configuration.property(name: "lineSpacing")
        paragraphSpacing = configuration.property(name: "paragraphSpacing")
        paragraphSpacingBefore = configuration.property(name: "paragraphSpacingBefore")

        super.init(configuration: configuration)
    }
}

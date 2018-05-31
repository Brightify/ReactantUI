//
//  AttributedText.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 25/05/2018.
//

import Foundation
#if ReactantRuntime
import UIKit
import Reactant
#endif

public class AttributedText: XMLElementDeserializable {
    
}

public class AttributedTextProperties: PropertyContainer {
    public let font: AssignablePropertyDescription<Font>
//    public let paragraphStyle: AssignablePropertyDescription<NSParagraphStyle>
    public let backgroundColor: AssignablePropertyDescription<UIColorPropertyType>
    public let ligature: AssignablePropertyDescription<Int>
    public let kern: AssignablePropertyDescription<Float>
    public let underlineStyle: AssignablePropertyDescription<UnderlineStyle>
    public let striketroughStyle: AssignablePropertyDescription<UnderlineStyle>
    public let strokeColor: AssignablePropertyDescription<UIColorPropertyType>
    public let strokeWidth: AssignablePropertyDescription<Float>
    public let shadowColor: AssignablePropertyDescription<UIColorPropertyType>
    public let shadowOffset: AssignablePropertyDescription<Float>
    public let shadowRadius: AssignablePropertyDescription<Float>
//    public let textEffect: AssignablePropertyDescription<String>
    public let attachmentImage: AssignablePropertyDescription<Image>
    // TODO: there are more missing attachment possibilities IIRC, need to decide if they're to be added
    public let linkURL: AssignablePropertyDescription<URL>
    public let link: AssignablePropertyDescription<TransformedText>
    public let baselineOffset: AssignablePropertyDescription<Float>
    public let underlineColor: AssignablePropertyDescription<UIColorPropertyType>
    public let strikethroughColor: AssignablePropertyDescription<UIColorPropertyType>
    public let obliqueness: AssignablePropertyDescription<Float>
    public let expansion: AssignablePropertyDescription<Float>
    public let writingDirection: AssignablePropertyDescription<WritingDirection>
    public let verticalGlyphForm: AssignablePropertyDescription<Int>

    public required init(configuration: Configuration) {
        font = configuration.property(name: "font")
//        paragraphStyle = configuration.property(name: "paragraphStyle")
        backgroundColor = configuration.property(name: "backgroundColor")
        ligature = configuration.property(name: "ligature")
        kern = configuration.property(name: "kern")
        striketroughStyle = configuration.property(name: "striketroughStyle")
        underlineStyle = configuration.property(name: "underlineStyle")
        strokeColor = configuration.property(name: "strokeColor")
        strokeWidth = configuration.property(name: "strokeWidth")
        shadowColor = configuration.property(name: "shadowColor")
        shadowOffset = configuration.property(name: "shadowOffset")
        shadowRadius = configuration.property(name: "shadowRadius")
//        textEffect = configuration.property(name: "textEffect")
        attachmentImage = configuration.property(name: "attachment")
        linkURL = configuration.property(name: "linkURL")
        link = configuration.property(name: "link")
        baselineOffset = configuration.property(name: "baselineOffset")
        underlineColor = configuration.property(name: "underlineColor")
        strikethroughColor = configuration.property(name: "strikethroughColor")
        obliqueness = configuration.property(name: "obliqueness")
        expansion = configuration.property(name: "expansion")
        writingDirection = configuration.property(name: "writingDirection")
        verticalGlyphForm = configuration.property(name: "verticalGlyphForm")

        super.init(configuration: configuration)
    }
}

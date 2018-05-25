//
//  AttributedText.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 25/05/2018.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public class AttributedText: XMLElementDeserializable {
    
}

public class AttributedTextProperties: PropertyContainer {
    public let font: AssignablePropertyDescription<UIFont>
    public let paragraphStyle: AssignablePropertyDescription<NSParagraphStyle>
    public let backgroundColor: AssignablePropertyDescription<UIColorPropertyType>
    public let ligature: AssignablePropertyDescription<Int>
    public let kern: AssignablePropertyDescription<Float>
    public let striketroughStyle: AssignablePropertyDescription<NSUnderlineStyle>
    public let underlineStyle: AssignablePropertyDescription<NSUnderlineStyle>
    public let strokeColor: AssignablePropertyDescription<UIColor>
    public let strokeWidth: AssignablePropertyDescription<Float>
    public let shadow: AssignablePropertyDescription<NSShadow>
    public let textEffect: AssignablePropertyDescription<String>
    public let attachment: AssignablePropertyDescription<NSTextAttachment>
    public let linkURL: AssignablePropertyDescription<URL>
    public let link: AssignablePropertyDescription<String>
    public let baselineOffset: AssignablePropertyDescription<Float>
    public let underlineColor: AssignablePropertyDescription<UIColor>
    public let strikethroughColor: AssignablePropertyDescription<UIColor>
    public let obliqueness: AssignablePropertyDescription<Float>
    public let expansion: AssignablePropertyDescription<Float>
    public let writingDirection: AssignablePropertyDescription<NSWritingDirection>
    public let verticalGlyphForm: AssignablePropertyDescription<Int>

    public required init(configuration: Configuration) {
        font = configuration.property(name: "font")
        paragraphStyle = configuration.property(name: "paragraphStyle")
        backgroundColor = configuration.property(name: "backgroundColor")
        ligature = configuration.property(name: "ligature")
        kern = configuration.property(name: "kern")
        striketroughStyle = configuration.property(name: "striketroughStyle")
        underlineStyle = configuration.property(name: "underlineStyle")
        strokeColor = configuration.property(name: "strokeColor")
        strokeWidth = configuration.property(name: "strokeWidth")
        shadow = configuration.property(name: "shadow")
        textEffect = configuration.property(name: "textEffect")
        attachment = configuration.property(name: "attachment")
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

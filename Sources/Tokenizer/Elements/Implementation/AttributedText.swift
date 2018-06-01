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

extension Set {
    fileprivate func inserting(_ elements: [Element]) -> Set<Element> {
        var set = self
        for element in elements {
            set.insert(element)
        }
        return set
    }

    fileprivate func inserting(_ elements: Element...) -> Set<Element> {
        return self.inserting(elements)
    }
}

//extension Attribute {
//    fileprivate static var comparison: (Attribute, Attribute) -> Bool {
//        return { (lhsAttribute, rhsAttribute) -> Bool in
//            if case .font = lhsAttribute, case .font = rhsAttribute {}
//            else if case .paragraphStyle = lhsAttribute, case .paragraphStyle = rhsAttribute {}
//            else if case .foregroundColor = lhsAttribute, case .foregroundColor = rhsAttribute {}
//            else if case .backgroundColor = lhsAttribute, case .backgroundColor = rhsAttribute {}
//            else if case .ligature = lhsAttribute, case .ligature = rhsAttribute {}
//            else if case .kern = lhsAttribute, case .kern = rhsAttribute {}
//            else if case .striketroughStyle = lhsAttribute, case .striketroughStyle = rhsAttribute {}
//            else if case .strokeColor = lhsAttribute, case .strokeColor = rhsAttribute {}
//            else if case .strokeWidth = lhsAttribute, case .strokeWidth = rhsAttribute {}
//            else if case .shadow = lhsAttribute, case .shadow = rhsAttribute {}
//            else if case .textEffect = lhsAttribute, case .textEffect = rhsAttribute {}
//            else if case .linkURL = lhsAttribute, case .linkURL = rhsAttribute {}
//            else if case .link = lhsAttribute, case .link = rhsAttribute {}
//            else if case .baselineOffset = lhsAttribute, case .baselineOffset = rhsAttribute {}
//            else if case .underlineColor = lhsAttribute, case .underlineColor = rhsAttribute {}
//            else if case .strikethroughColor = lhsAttribute, case .strikethroughColor = rhsAttribute {}
//            else if case .obliqueness = lhsAttribute, case .obliqueness = rhsAttribute {}
//            else if case .expansion = lhsAttribute, case .expansion = rhsAttribute {}
//            else if case .writingDirection = lhsAttribute, case .writingDirection = rhsAttribute {}
//            else if case .verticalGlyphForm = lhsAttribute, case .verticalGlyphForm = rhsAttribute {}
//            else { return false }
//            return true
//        }
//    }
//
//    // TODO: fileprivate when implementation is done?
//    var description: String {
//        switch self {
//        case .font:
//            return "font"
//        case .paragraphStyle:
//            return "paragraphStyle"
//        case .foregroundColor:
//            return "foregroundColor"
//        case .backgroundColor:
//            return "backgroundColor"
//        case .ligature:
//            return "ligature"
//        case .kern:
//            return "kern"
//        case .striketroughStyle:
//            return "strikethroughStyle"
//        case .underlineStyle:
//            return "underlineStyle"
//        case .strokeColor:
//            return "strokeColor"
//        case .strokeWidth:
//            return "strokeWidth"
//        case .shadow:
//            return "shadow"
//        case .textEffect:
//            return "textEffect"
//        case .attachment:
//            return "attachment"
//        case .linkURL:
//            return "link"
//        case .link:
//            return "link"
//        case .baselineOffset:
//            return "baselineOffset"
//        case .underlineColor:
//            return "underlineColor"
//        case .strikethroughColor:
//            return "strikethroughColor"
//        case .obliqueness:
//            return "obliqueness"
//        case .expansion:
//            return "expansion"
//        case .writingDirection:
//            return "writingDirection"
//        case .verticalGlyphForm:
//            return "verticalGlyphForm"
//        }
//    }
//}

// "lolek <b>lolkaro <i>oto</i> megre<s><u>IMPO</u></s></b> lolker"
// var string = MutableAttrString("")
// string.append("lolek")
// string.append("lolkaro".attributed(.font(1)))
// string.append("oto".attributed(.font(1), .foregroundColor(red)))
// string.append("megre".attributed(.font(1)))
// string.append("IMPO".attributed(.strikethroughStyle(yes), .underlineStyle(yes)))
// string.append("lolker")
public enum AttributedText {
    case transform(TransformedText)
    indirect case attributed(AttributedTextStyle, [AttributedText])
}

extension AttributedText: SupportedPropertyType {
    public var generated: String {
        func resolveAttributes(text: AttributedText, attributes: [Property]) -> String {
            switch text {
            case .transform(let transformedText):
                let attributesString = attributes.map { ".\($0.name)" }.joined(separator: ", ")
                return "\(transformedText.generated).attributed(\(attributesString))"
//            case .text(let attributedText):
//                return resolveAttributes(text: attributedText, attributes: attributes)
            case .attributed(let attributedStyle, let attributedTexts):
                // the order of appending is important because the `distinct(where:)` keeps the first element of the duplicates
                let lowerAttributes = attributedStyle.properties
                    .arrayByAppending(attributes)
                    .distinct(where: { $0.name == $1.name })
                return attributedTexts.map { resolveAttributes(text: $0, attributes: lowerAttributes) }.joined()
            }
        }
        return resolveAttributes(text: self, attributes: [])
    }

    #if SanAndreas
    public func dematerialize() -> String {
        func resolveTransformations(text: AttributedText) -> String {
            switch text {
            case .transform(.uppercased, let inner):
                return ":uppercased(\(resolveTransformations(text: inner)))"
            case .transform(.lowercased, let inner):
                return ":lowercased(\(resolveTransformations(text: inner)))"
            case .transform(.localized, let inner):
                return ":localized(\(resolveTransformations(text: inner)))"
            case .transform(.capitalized, let inner):
                return ":capitalized(\(resolveTransformations(text: inner)))"
            case .text(let value):
                return value.replacingOccurrences(of: "\"", with: "&quot;")
                    .replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\r", with: "\\r")
            }
        }
        return resolveTransformations(text: self)
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        func resolveAttributes(text: AttributedText, attributes: [Property]) -> NSAttributedString {
            switch text {
            case .transform(let transformedText):
                let attributesString = attributes.map { ".\($0.name)" }.joined(separator: ", ")
                return transformedText.generated.attributed() //.attributed(\(attributesString))
            case .attributed(let attributedStyle, let attributedTexts):
                // the order of appending is important because the `distinct(where:)` keeps the first element of the duplicates
                let lowerAttributes = attributedStyle.properties
                    .arrayByAppending(attributes)
                    .distinct(where: { $0.name == $1.name })
                let mutableAttributedString = NSMutableAttributedString()
                for attributedText in attributedTexts {
                    let attributedString = resolveAttributes(text: attributedText, attributes: lowerAttributes)
                    mutableAttributedString.append(attributedString)
                }
                return mutableAttributedString
            }
        }
        return resolveAttributes(text: self, attributes: [])
    }
    #endif

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}

public class AttributedTextProperties: PropertyContainer {
    public let font: AssignablePropertyDescription<Font>
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
    public let linkURL: AssignablePropertyDescription<URL>
    public let link: AssignablePropertyDescription<TransformedText>
    public let baselineOffset: AssignablePropertyDescription<Float>
    public let underlineColor: AssignablePropertyDescription<UIColorPropertyType>
    public let strikethroughColor: AssignablePropertyDescription<UIColorPropertyType>
    public let obliqueness: AssignablePropertyDescription<Float>
    public let expansion: AssignablePropertyDescription<Float>
    public let writingDirection: AssignablePropertyDescription<WritingDirection>
    public let verticalGlyphForm: AssignablePropertyDescription<Int>

    public let paragraphStyle: ParagraphStyleProperties

    public required init(configuration: Configuration) {
        font = configuration.property(name: "font")
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

        paragraphStyle = configuration.namespaced(in: "paragraphStyle", ParagraphStyleProperties.self)

        super.init(configuration: configuration)
    }
}

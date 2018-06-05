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

///// Enum which represents NS attributes for NSAttributedString (like NSStrokeColorAttributeName). Each case has value and assigned name.
//public enum AttributedTextAttribute {
//    case font(Font)
//    case foregroundColor(UIColorPropertyType)
//    case backgroundColor(UIColorPropertyType)
//    case ligature(Int)
//    case kern(Float)
//    case striketroughStyle(UnderlineStyle)
//    case underlineStyle(UnderlineStyle)
//    case strokeColor(UIColorPropertyType)
//    case strokeWidth(Float)
//    case shadowColor(UIColorPropertyType)
//    case textEffect(String)
//    case attachmentImage(Image)
//    case linkURL(URL)
//    case link(TransformedText)
//    case baselineOffset(Float)
//    case underlineColor(UIColorPropertyType)
//    case strikethroughColor(UIColorPropertyType)
//    case obliqueness(Float)
//    case expansion(Float)
//    case writingDirection(WritingDirection)
//    case verticalGlyphForm(Int)
////    case paragraphStyle(NSParagraphStyle)
//}
//
//extension AttributedTextAttribute {
//    var description: String {
//        switch self {
//        case .font:
//            return "font"
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
////        case .shadow:
////            return "shadow"
////        case .textEffect:
////            return "textEffect"
//        case .attachmentImage:
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
////        case .paragraphStyle:
////            return "paragraphStyle"
//        }
//    }
//}

//extension Attribute {
//    fileprivate static var comparison: (Attribute, Attribute) -> Bool {
//        return { (lhsAttribute, rhsAttribute) -> Bool in
//            switch (lhsAttribute, rhsAttribute) {
//            case (.font, .font), (.paragraphStyle, .paragraphStyle), (.foregroundColor, .foregroundColor):
//                return true
//            default:
//                return false
//            }
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
//}

extension Array {

    fileprivate func arrayByAppending(_ elements: Element...) -> Array<Element> {
        return arrayByAppending(elements)
    }

    fileprivate func arrayByAppending(_ elements: [Element]) -> Array<Element> {
        var mutableCopy = self
        mutableCopy.append(contentsOf: elements)
        return mutableCopy
    }
}

extension Sequence {
    fileprivate func distinct(where comparator: (_ lhs: Iterator.Element, _ rhs: Iterator.Element) -> Bool) -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self where result.contains(where: { comparator(item, $0) }) == false {
            result.append(item)
        }
        return result
    }
}

public struct AttributedText: ElementSupportedPropertyType {
    public let style: StyleName?
    public let localProperties: [Property]
    public let parts: [AttributedText.Part]

    public enum Part {
        case transform(TransformedText)
        indirect case attributed(AttributedTextStyle, [AttributedText.Part])
    }
}

extension AttributedText {
    public func generate(context: SupportedPropertyTypeContext) -> String {
        func resolveAttributes(part: AttributedText.Part, inheritedAttributes: [Property], parentElements: [String]) -> [String] {
            switch part {
            case .transform(let transformedText):
                let generatedAttributes = inheritedAttributes.map {
                    ".\($0.name)(\($0.anyValue.generate(context: context.sibling(for: $0.anyValue))))"
                    }.joined(separator: ", ")
                let generatedTransformedText = transformedText.generate(context: context.sibling(for: transformedText))
                let generatedParentStyles = parentElements.compactMap { elementName in
                    // TODO Implement support for global styles
                    style.map { context.localStyle(named: $0.name) + ".\(elementName)" }
                }
                let attributesString = (generatedParentStyles + ["[\(generatedAttributes)]"]).joined(separator: " + ")
                return ["\(generatedTransformedText).attributed(\(attributesString))"]
            case .attributed(let attributedStyle, let attributedTexts):
                // the order of appending is important because the `distinct(where:)` keeps the first element of the duplicates
                let lowerAttributes = attributedStyle.properties
                    .arrayByAppending(inheritedAttributes)
                    .distinct(where: { $0.name == $1.name })
                let newParentElements = parentElements + [attributedStyle.name]

                return attributedTexts.flatMap {
                    resolveAttributes(part: $0, inheritedAttributes: lowerAttributes, parentElements: newParentElements)
                }
            }
        }

        let mutableStringParts = parts.flatMap {
            resolveAttributes(part: $0, inheritedAttributes: localProperties, parentElements: [])
        }

        return """
        {
            let s = NSMutableAttributedString()
            \(mutableStringParts.map { "s.append(\($0))" }.joined(separator: "\n"))
            return s
        }()
        """
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
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return nil
//        func resolveAttributes(text: AttributedText, attributes: [Property]) -> NSAttributedString {
//            switch text {
//            case .transform(let transformedText):
//                let attributesString = attributes.map { ".\($0.name)" }.joined(separator: ", ")
//                return transformedText.generate(context: context.sibling(for: transformedText)).attributed()
//            case .attributed(let attributedStyle, let attributedTexts):
//                // the order of appending is important because the `distinct(where:)` keeps the first element of the duplicates
//                let lowerAttributes = attributedStyle.properties
//                    .arrayByAppending(attributes)
//                    .distinct(where: { $0.name == $1.name })
//                let mutableAttributedString = NSMutableAttributedString()
//                for attributedText in attributedTexts {
//                    let attributedString = resolveAttributes(text: attributedText, attributes: lowerAttributes)
//                    mutableAttributedString.append(attributedString)
//                }
//                return mutableAttributedString
//            }
//        }
//        return resolveAttributes(text: self, attributes: [])
    }
    #endif

    public static func materialize(from element: XMLElement) throws -> AttributedText {
        let styleName = element.value(ofAttribute: "style") as StyleName?

        func parseTextElement(contents: [XMLContent]) throws -> [AttributedText.Part] {
            return try contents.map { content in
                switch content {
                case let textChild as TextElement:
                    return .transform(try TransformedText.materialize(from: textChild.text))
                case let elementChild as XMLElement:
                    let textStyle = try AttributedTextStyle(node: elementChild)
                    return .attributed(textStyle, try parseTextElement(contents: elementChild.children))
                default:
                    throw PropertyMaterializationError.unknownValue("Content is neither TextElement nor XMLElement - \(content)")
                }
            }
        }

        func trimmingWhitespace(content: XMLContent, leading: Bool, indentationLevel: inout Int) throws -> XMLContent? {
            switch content {
            case let textChild as TextElement:
                let trimmedText = textChild.text.replacingOccurrences(of: leading ? "^\\s+" : "\\s+$",
                                                              with: "",
                                                              options: .regularExpression)
                if leading {
                    indentationLevel = textChild.text.count - trimmedText.count
                }
                guard !trimmedText.isEmpty else { return nil }
                return TextElement(text: trimmedText)

            case let elementChild as XMLElement:
                let index = leading ? elementChild.children.startIndex : elementChild.children.endIndex
                guard let modifiedChild = try trimmingWhitespace(content: elementChild.children[index], leading: leading, indentationLevel: &indentationLevel)
                    else { return elementChild }
                elementChild.children[index] = modifiedChild
                return elementChild

            default:
                throw PropertyMaterializationError.unknownValue("Content is neither TextElement nor XMLElement - \(content)")
            }
        }

        func fixingContentIndentation(content: XMLContent, indentationLevel: Int) throws -> XMLContent {
            switch content {
            case let textChild as TextElement:
                let fixedText = textChild.text.replacingOccurrences(of: "\\n[ ]{0,\(indentationLevel)}",
                                                                      with: "\\\n",
                                                                      options: .regularExpression)
                return TextElement(text: fixedText)

            case let elementChild as XMLElement:
                let index = elementChild.children.startIndex
                elementChild.children[index] = try fixingContentIndentation(content: elementChild.children[index], indentationLevel: indentationLevel)
                return elementChild

            default:
                throw PropertyMaterializationError.unknownValue("Content is neither TextElement nor XMLElement - \(content)")
            }
        }

        var indentationLevel = 0
        let trimmedContents: [XMLContent] = try element.children.enumerated().compactMap { (index, content) in
                switch index {
                case 0:
                    return try trimmingWhitespace(content: content, leading: true, indentationLevel: &indentationLevel)
                case element.children.count - 1:
                    let indentedContent = try fixingContentIndentation(content: content, indentationLevel: indentationLevel)
                    return try trimmingWhitespace(content: indentedContent, leading: false, indentationLevel: &indentationLevel)
                default:
                    return try fixingContentIndentation(content: content, indentationLevel: indentationLevel)
                }
            }

        let parsedText = try parseTextElement(contents: trimmedContents)
        // FIXME: `AttributedTextStyle` shouldn't be reused here and we should parse the properties ourselves
        let style = try AttributedTextStyle(node: element)
        return AttributedText(style: styleName, localProperties: style.properties, parts: parsedText)
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}

public class AttributedTextProperties: PropertyContainer {
    public let font: AssignablePropertyDescription<Font>
    public let foregroundColor: AssignablePropertyDescription<UIColorPropertyType>
    public let backgroundColor: AssignablePropertyDescription<UIColorPropertyType>
    public let ligature: AssignablePropertyDescription<Int>
    public let kern: AssignablePropertyDescription<Float>
    public let underlineStyle: AssignablePropertyDescription<UnderlineStyle>
    public let striketroughStyle: AssignablePropertyDescription<UnderlineStyle>
    public let strokeColor: AssignablePropertyDescription<UIColorPropertyType>
    public let strokeWidth: AssignablePropertyDescription<Float>
    public let shadowColor: AssignablePropertyDescription<UIColorPropertyType>
    public let shadowOffset: AssignablePropertyDescription<Size>
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
        foregroundColor = configuration.property(name: "foregroundColor")
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

//
//  AttributedText.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 25/05/2018.
//

import Foundation
#if canImport(UIKit)
import UIKit
import Hyperdrive
#endif

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
        for item in self where !result.contains(where: { comparator(item, $0) }) {
            result.append(item)
        }
        return result
    }
}

public struct AttributedText: ElementSupportedPropertyType {
    public static let runtimeType = RuntimeType(name: "NSMutableAttributedString", module: "Foundation")

    public let style: StyleName?
    public let localProperties: [Property]
    public let parts: [AttributedText.Part]

    public var requiresTheme: Bool {
        return localProperties.contains(where: { $0.anyValue.requiresTheme }) ||
            parts.contains(where: { $0.requiresTheme })
    }

    public enum Part {
        case transform(TransformedText)
        indirect case attributed(AttributedTextStyle, [AttributedText.Part])

        var requiresTheme: Bool {
            switch self {
            case .transform:
                return false
            case .attributed(let style, let innerText):
                return style.properties.contains(where: { $0.anyValue.requiresTheme }) ||
                    innerText.contains(where: { $0.requiresTheme })
            }
        }
    }
}

extension AttributedText {
    static let attributeKeys = [
        "font": NSAttributedString.Key.font,
        "foregroundColor": NSAttributedString.Key.foregroundColor,
        "backgroundColor": NSAttributedString.Key.backgroundColor,
        "ligature": NSAttributedString.Key.ligature,
        "kern": NSAttributedString.Key.kern,
        "underlineStyle": NSAttributedString.Key.underlineStyle,
        "underlineColor": NSAttributedString.Key.underlineColor,
        "striketroughStyle": NSAttributedString.Key.strikethroughStyle,
        "strikethroughColor": NSAttributedString.Key.strikethroughColor,
        "strokeColor": NSAttributedString.Key.strokeColor,
        "strokeWidth": NSAttributedString.Key.strokeWidth,
        "shadow": NSAttributedString.Key.shadow,
        "attachmentImage": NSAttributedString.Key.attachment,
        "link": NSAttributedString.Key.link,
        "baselineOffset": NSAttributedString.Key.baselineOffset,
        "obliqueness": NSAttributedString.Key.obliqueness,
        "expansion": NSAttributedString.Key.expansion,
        "writingDirection": NSAttributedString.Key.writingDirection,
        "verticalGlyphForm": NSAttributedString.Key.verticalGlyphForm,
        "paragraphStyle": NSAttributedString.Key.paragraphStyle,
    ] as [String: NSAttributedString.Key]

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
                guard !elementChild.children.isEmpty else { return elementChild }
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
                let fixedText = textChild.text.replacingOccurrences(
                    of: "\\n[ ]{0,\(indentationLevel)}",
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
            case 0 where element.children.count == 1:
                guard let partialResult = try trimmingWhitespace(content: content, leading: true, indentationLevel: &indentationLevel) else { return nil }
                return try trimmingWhitespace(content: partialResult, leading: false, indentationLevel: &indentationLevel)
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

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return """
        {
            let s = NSMutableAttributedString()
            \(generateStringParts(context: context).map { "s.append((\($0.text)).attributed(\($0.attributes)))" }.joined(separator: "\n\t"))
            return s
        }()
        """
    }

    private func generateStringParts(context: SupportedPropertyTypeContext) -> [(text: String, attributes: String)] {
        func resolveAttributes(part: AttributedText.Part, inheritedAttributes: [Property], parentElements: [String]) -> [(text: String, attributes: String)] {
            switch part {
            case .transform(let transformedText):
                let generatedAttributes = inheritedAttributes.map {
                    ".\($0.name)(\($0.anyValue.generate(context: context.child(for: $0.anyValue))))"
                }.joined(separator: ", ")
                let generatedTransformedText = transformedText.generate(context: context.child(for: transformedText))
                let generatedParentStyles = parentElements.compactMap { elementName in
                    style.map { context.resolvedStyleName(named: $0) + ".\(elementName)" }
                }.distinctLast()

                let attributesString = (generatedParentStyles + ["[\(generatedAttributes)]"]).joined(separator: " + ")
                return [(generatedTransformedText, attributesString)]
            case .attributed(let attributedStyle, let attributedTexts):
                let resolvedAttributes: Set<String>
                if let styleName = style {
                    resolvedAttributes = Set(resolvedExtensions(of: attributedStyle, from: [styleName], in: context).map { $0.name })
                } else {
                    resolvedAttributes = []
                }
                // the order of appending is important because the `distinct(where:)` keeps the first element of the duplicates
                let lowerAttributes = attributedStyle.properties
                    .arrayByAppending(inheritedAttributes.filter { !resolvedAttributes.contains($0.name) })
                    .distinct(where: { $0.name == $1.name })
                let newParentElements = parentElements + [attributedStyle.name]

                return attributedTexts.flatMap {
                    resolveAttributes(part: $0, inheritedAttributes: lowerAttributes, parentElements: newParentElements)
                }
            }
        }

        return parts.flatMap {
            resolveAttributes(part: $0, inheritedAttributes: localProperties, parentElements: [])
            }.reduce([]) { current, stringPart in
                guard let lastStringPart = current.last, lastStringPart.attributes == stringPart.attributes else {
                    return current.arrayByAppending(stringPart)
                }
                var mutableCurrent = current
                mutableCurrent[mutableCurrent.endIndex - 1] = (text: "\(lastStringPart.text) + \(stringPart.text)", attributes: lastStringPart.attributes)
                return mutableCurrent
        } as [(text: String, attributes: String)]
    }

    private func resolvedExtensions(of style: AttributedTextStyle, from styleNames: [StyleName], in context: SupportedPropertyTypeContext) -> [Property] {
        return styleNames.flatMap { styleName -> [Property] in
            guard let resolvedStyle = context.style(named: styleName),
                case .attributedText(let styles) = resolvedStyle.type,
                let extendedAttributeStyle = styles.first(where: { $0.name == style.name }) else { return [] }

            return extendedAttributeStyle.properties.arrayByAppending(resolvedExtensions(of: style, from: resolvedStyle.extend, in: context))
        }
    }

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        fatalError("Implement me!")
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        func resolveAttributes(part: AttributedText.Part, inheritedAttributes: [Property]) -> [NSAttributedString] {
            switch part {
            case .transform(let transformedText):
                guard let transformedText = transformedText.runtimeValue(context: context.child(for: transformedText)) as? String
                    else { return [] }

                let attributes = Dictionary(keyValueTuples: inheritedAttributes.compactMap { attribute -> (NSAttributedString.Key, Any)? in
                    guard let attributeValue = attribute.anyValue.runtimeValue(context: context.child(for: attribute.anyValue)),
                        let key = AttributedText.attributeKeys[attribute.name] else { return nil }
                    return (key, attributeValue)
                })
                return [NSAttributedString(string: transformedText, attributes: attributes)]

            case .attributed(let attributedStyle, let attributedTexts):
                let resolvedAttributes: [Property]
                if let styleName = style {
                    resolvedAttributes = resolvedExtensions(of: attributedStyle, from: [styleName], in: context)
                } else {
                    resolvedAttributes = []
                }

                // the order of appending is important because the `distinct(where:)` keeps the first element of the duplicates
                let lowerAttributes = attributedStyle.properties
                    .arrayByAppending(resolvedAttributes)
                    .arrayByAppending(inheritedAttributes)
                    .distinct(where: { $0.name == $1.name })

                return attributedTexts.flatMap {
                    resolveAttributes(part: $0, inheritedAttributes: lowerAttributes)
                }
            }
        }

        let result = NSMutableAttributedString()
        parts
            .flatMap { resolveAttributes(part: $0, inheritedAttributes: localProperties) }
            .forEach { result.append($0) }
        return result
    }
    #endif

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
    public let strikethroughStyle: AssignablePropertyDescription<UnderlineStyle>
    public let strokeColor: AssignablePropertyDescription<UIColorPropertyType>
    public let strokeWidth: AssignablePropertyDescription<Float>
    public let shadow: MultipleAttributeAssignablePropertyDescription<Shadow>
//    public let textEffect: AssignablePropertyDescription<String>
    public let attachmentImage: AssignablePropertyDescription<Image>
    public let link: AssignablePropertyDescription<URL>
    public let baselineOffset: AssignablePropertyDescription<Float>
    public let underlineColor: AssignablePropertyDescription<UIColorPropertyType>
    public let strikethroughColor: AssignablePropertyDescription<UIColorPropertyType>
    public let obliqueness: AssignablePropertyDescription<Float>
    public let expansion: AssignablePropertyDescription<Float>
    public let writingDirection: AssignablePropertyDescription<WritingDirection>
    public let verticalGlyphForm: AssignablePropertyDescription<Int>

    public let paragraphStyle: MultipleAttributeAssignablePropertyDescription<ParagraphStyle>

    public required init(configuration: Configuration) {
        font = configuration.property(name: "font")
        foregroundColor = configuration.property(name: "foregroundColor")
        backgroundColor = configuration.property(name: "backgroundColor")
        ligature = configuration.property(name: "ligature")
        kern = configuration.property(name: "kern")
        strikethroughStyle = configuration.property(name: "strikethroughStyle")
        underlineStyle = configuration.property(name: "underlineStyle")
        strokeColor = configuration.property(name: "strokeColor")
        strokeWidth = configuration.property(name: "strokeWidth")
        shadow = configuration.property(name: "shadow")
//        textEffect = configuration.property(name: "textEffect")
        attachmentImage = configuration.property(name: "attachment")
        link = configuration.property(name: "link")
        baselineOffset = configuration.property(name: "baselineOffset")
        underlineColor = configuration.property(name: "underlineColor")
        strikethroughColor = configuration.property(name: "strikethroughColor")
        obliqueness = configuration.property(name: "obliqueness")
        expansion = configuration.property(name: "expansion")
        writingDirection = configuration.property(name: "writingDirection")
        verticalGlyphForm = configuration.property(name: "verticalGlyphForm")

        paragraphStyle = configuration.property(name: "paragraphStyle")

        super.init(configuration: configuration)
    }
}

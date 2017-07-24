import Foundation

public enum Font: SupportedPropertyType {
    case system(weight: SystemFontWeight, size: Float)
    case named(String, size: Float)

    public var generated: String {
        switch self {
        case .system(let weight, let size):
            return "UIFont.systemFont(ofSize: \(size), weight: \(weight.name))"
        case .named(let name, let size):
            return "UIFont(\"\(name)\", \(size))"
        }
    }

    public static func materialize(from value: String) throws -> Font {
        let tokens = Lexer.tokenize(input: value, keepWhitespace: true)
        return try FontParser(tokens: tokens).parseSingle()
    }
}

#if ReactantRuntime
    import UIKit

    extension Font {

        public var runtimeValue: Any? {
            switch self {
            case .system(let weight, let size):
                return UIFont.systemFont(ofSize: CGFloat(size), weight: weight.value)
            case .named(let name, let size):
                return UIFont(name, CGFloat(size))
            }
        }
    }
#endif

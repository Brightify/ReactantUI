import Foundation
import Tokenizer
import SwiftCodeGen

public enum SwiftVersion: Int {
    case swift4_0
    case swift4_1

    public init?(raw: String) {
        switch raw {
        case "4.0":
            self = .swift4_0
        case "4.1":
            self = .swift4_1
        default:
            return nil
        }
    }
}

extension SwiftVersion: Comparable {
    public static func <(lhs: SwiftVersion, rhs: SwiftVersion) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct GeneratorConfiguration {
    public let minimumMajorVersion: Int
    public let localXmlPath: String
    public let isLiveEnabled: Bool
    public let swiftVersion: SwiftVersion
    public let defaultModifier: AccessModifier
    
    public init(minimumMajorVersion: Int,
                localXmlPath: String,
                isLiveEnabled: Bool,
                swiftVersion: SwiftVersion,
                defaultModifier: AccessModifier) {
        self.minimumMajorVersion = minimumMajorVersion
        self.localXmlPath = localXmlPath
        self.isLiveEnabled = isLiveEnabled
        self.swiftVersion = swiftVersion
        self.defaultModifier = defaultModifier
    }
}

public struct GeneratorError: Error, LocalizedError {
    public let message: String

    public var errorDescription: String? {
        return message
    }

    public var localizedDescription: String {
        return message
    }
}

public class Generator {
    public enum Encapsulation {
        case none
        case parentheses
        case brackets
        case braces
        case custom(open: String, close: String)

        var open: String {
            switch self {
            case .none:
                return ""
            case .parentheses:
                return "("
            case .brackets:
                return "["
            case .braces:
                // FIXME Let's think about the space here, do we want to remove it?
                return " {"
            case .custom(let open, _):
                return open
            }
        }

        var close: String {
            switch self {
            case .none:
                return ""
            case .parentheses:
                return ")"
            case .brackets:
                return "]"
            case .braces:
                return "}"
            case .custom(_, let close):
                return close
            }
        }
    }

    let configuration: GeneratorConfiguration

    var nestLevel: Int = 0

    init(configuration: GeneratorConfiguration) {
        self.configuration = configuration
    }
    
    var output = ""

    func generate(imports: Bool) throws -> Describable {
        return ""
    }
    
    func ifSimulator(_ commands: String) -> [String] {
        if configuration.swiftVersion >= .swift4_1 {
            return [
                "#if targetEnvironment(simulator)",
                "    \(commands)",
                "#endif",
            ]
        } else {
            return [
                "#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))",
                "    \(commands)",
                "#endif",
            ]
        }
    }
}

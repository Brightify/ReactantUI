import Foundation
import Tokenizer

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
            }
        }
    }

    let configuration: GeneratorConfiguration

    var nestLevel: Int = 0

    init(configuration: GeneratorConfiguration) {
        self.configuration = configuration
    }
    
    var output = ""

    func generate(imports: Bool) throws -> String {
        return output
    }

    func l(_ line: String = "") {
        l(fakeLine: line)
    }

    func l(_ line: String = "", encapsulateIn encapsulation: Encapsulation = .braces, _ f: () throws -> Void) rethrows {
        l(fakeLine: line + encapsulation.open)
        nestLevel += 1
        try f()
        nestLevel -= 1
        l(encapsulation.close)
    }

    private func l(fakeLine: String) {
        let lines = fakeLine.components(separatedBy: CharacterSet.newlines)
        for line in lines {
            output.append((0..<nestLevel).map { _ in "    " }.joined() + line + "\n")
        }
    }
    
    func ifSimulator(_ commands: String) -> String {
        if configuration.swiftVersion >= .swift4_1 {
            return """
            #if targetEnvironment(simulator) || DEBUG
                \(commands)
            #endif
            """
        } else {
            return """
            #if ((arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))) || DEBUG
                \(commands)
            #endif
            """
        }
    }
}

import Generator
import Tokenizer
import Foundation

let enableLive = CommandLine.arguments.contains("--enable-live")

let currentPath = FileManager.default.currentDirectoryPath
let currentPathUrl = URL(fileURLWithPath: currentPath)

let uiXmlEnumerator = FileManager.default.enumerator(atPath: currentPath)
let uiFiles = uiXmlEnumerator?.flatMap { $0 as? String }.filter { $0.hasSuffix(".ui.xml") }
    .map { currentPathUrl.appendingPathComponent($0).path } ?? []

let styleXmlEnumerator = FileManager.default.enumerator(atPath: currentPath)
let styleFiles = styleXmlEnumerator?.flatMap { $0 as? String }.filter { $0.hasSuffix(".styles.xml") }
    .map { currentPathUrl.appendingPathComponent($0).path } ?? []

var stylePaths = [] as [String]
for (index, path) in styleFiles.enumerated() {
    print("// Generated from \(path)")
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))

    let xml = SWXMLHash.parse(data)
    let group: StyleGroup = try! xml["styleGroup"].value()
    stylePaths.append(path)
    StyleGenerator(group: group, localXmlPath: path, isLiveEnabled: enableLive)
        .generate(imports: index == 0)
}

// FIXME create generator
var componentTypes: [String] = []
var componentDefinitions: [String: ComponentDefinition] = [:]
var imports: Set<String> = []
for (index, path) in uiFiles.enumerated() {
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))

    let xml = SWXMLHash.parse(data)

    let node = xml["Component"].element!
    var definition: ComponentDefinition
    if let type: String = xml["Component"].value(ofAttribute: "type") {
        definition = try! ComponentDefinition(node: node, type: type)
    } else {
        definition = try! ComponentDefinition(node: node, type: componentType(from: path))
    }
    componentTypes.append(contentsOf: definition.componentTypes)
    componentDefinitions[path] = definition
    imports.formUnion(definition.requiredImports)
}

print("import UIKit")
print("import Reactant")
print("import SnapKit")
if enableLive {
    print("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
    print("import ReactantLiveUI")
    print("#endif")
}
for imp in imports {
    print("import \(imp)")
}

for (path, rootDefinition) in componentDefinitions {
    print("// Generated from \(path)")
    for definition in rootDefinition.componentDefinitions {
        UIGenerator(definition: definition, localXmlPath: path, isLiveEnabled: enableLive)
            .generate(imports: false)
    }
}


if enableLive {
    print("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
    print("struct GeneratedReactantLiveUIConfiguration: ReactantLiveUIConfiguration {")
    print("    let rootDir = \"\(currentPath)\"")

    print("    let commonStylePaths: [String] = [")
    for path in stylePaths {
        print("        \"\(path)\",")
    }
    print("    ]")

    if componentTypes.isEmpty {
        print("    let componentTypes: [String: UIView.Type] = [:]")
    } else {
        print("    let componentTypes: [String: UIView.Type] = [")
        for type in Set(componentTypes) {
            print("        \"\(type)\": \(type).self,")
        }
        print("    ]")
    }
    print("}")
    print("#endif")
}

print("func activateLiveReload(in window: UIWindow) {")
if enableLive {
    print("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
    print("ReactantLiveUIManager.shared.activate(in: window, configuration: GeneratedReactantLiveUIConfiguration())")
    print("#endif")
}
print("}")

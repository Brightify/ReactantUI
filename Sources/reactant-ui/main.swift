import FileKit
import Generator
import Tokenizer
import Foundation

let enableLive = CommandLine.arguments.contains("--enable-live")

let uiFiles = Path.current.find(searchDepth: -1) { path in
    path.fileName.hasSuffix(".ui.xml")
}

let styleFiles = Path.current.find(searchDepth: -1) { path in
    path.fileName.hasSuffix(".styles.xml")
}

var stylePaths = [] as [String]

for (index, path) in styleFiles.enumerated() {
    print("// Generated from \(path)")
    let file = DataFile(path: path)
    let data = try! file.read()

    let xml = SWXMLHash.parse(data)
    let group: StyleGroup = try! xml["styleGroup"].value()
    stylePaths.append(path.absolute.rawValue)
    StyleGenerator(group: group, localXmlPath: path.absolute.rawValue, isLiveEnabled: enableLive)
        .generate(imports: index == 0)
}

// FIXME create generator
var componentTypes: [String] = []
var componentDefinitions: [Path: ComponentDefinition] = [:]
var imports: Set<String> = []
for (index, path) in uiFiles.enumerated() {
    let file = DataFile(path: path)
    let data = try! file.read()

    let xml = SWXMLHash.parse(data)

    let node = xml["Component"].element!
    var definition: ComponentDefinition
    if let type: String = xml["Component"].value(ofAttribute: "type") {
        definition = try! ComponentDefinition(node: node, type: type)
    } else {
        definition = try! ComponentDefinition(node: node, type: componentType(from: path.fileName))
    }
    componentTypes.append(contentsOf: definition.componentTypes)
    componentDefinitions[path] = definition
    imports.formUnion(definition.requiredImports)
}

print("import UIKit")
print("import Reactant")
print("import SnapKit")
if enableLive {
    print("#if (arch(i386) || arch(x86_64)) && os(iOS)")
    print("import ReactantLiveUI")
    print("#endif")
}
for imp in imports {
    print("import \(imp)")
}

for (path, rootDefinition) in componentDefinitions {
    print("// Generated from \(path)")
    for definition in rootDefinition.componentDefinitions {
        UIGenerator(definition: definition, localXmlPath: path.absolute.rawValue, isLiveEnabled: enableLive)
            .generate(imports: false)
    }
}


if enableLive {
    print("#if (arch(i386) || arch(x86_64)) && os(iOS)")
    print("struct GeneratedReactantLiveUIConfiguration: ReactantLiveUIConfiguration {")
    print("    let rootDir = \"\(Path.current)\"")

    print("    let commonStylePaths: [String] = [")
    for path in stylePaths {
        print("        \"\(path)\",")
    }
    print("    ]")

    print("    let componentTypes: [String: UIView.Type] = [")
    for type in Set(componentTypes) {
        print("        \"\(type)\": \(type).self,")
    }
    print("    ]")
    print("}")
    print("#endif")
}

print("func activateLiveReload(in window: UIWindow) {")
if enableLive {
    print("#if (arch(i386) || arch(x86_64)) && os(iOS)")
    print("ReactantLiveUIManager.shared.activate(in: window, configuration: GeneratedReactantLiveUIConfiguration())")
    print("#endif")
}
print("}")

//
//  PlainTableView.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 4/22/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
import Hyperdrive
import RxDataSources
#endif

enum TableViewSource {
    case fielded
    case anonymous(Cell)
}

enum Cell {
    case name(String)
    case cell(ComponentDefinition)
}

public class PlainTableView: View, ComponentDefinitionContainer {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.plainTableView.allProperties
    }

    public override class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.plainTableView.allProperties
    }

    public var cellType: String?
    public var cellDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return cellDefinition?.componentTypes ?? [cellType].compactMap { $0 }
    }

    public var isAnonymous: Bool {
        return cellDefinition?.isAnonymous ?? false
    }

    public var componentDefinitions: [ComponentDefinition] {
        return cellDefinition?.componentDefinitions ?? []
    }
    
    public override class var parentModuleImport: String {
        return "Hyperdrive"
    }

    public class override func runtimeType() -> String {
        return "UITableView"
    }

    public override func initialization() -> String {
        guard let cellType = cellType else {
            return "Initialization should never happen as the view was referenced via field."
        }
        return "PlainTableView<\(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        if let field = node.value(ofAttribute: "field") as String?, !field.isEmpty {
            cellType = nil
            cellDefinition = nil
        } else {
            guard let cellType = node.value(ofAttribute: "cell") as String? else {
                throw TokenizationError(message: "cell for PlainTableView was not defined.")
            }

            self.cellType = cellType

            if let cellElement = try node.singleOrNoElement(named: "cell") {
                cellDefinition = try ComponentDefinition(node: cellElement, type: cellType)
            } else {
                cellDefinition = nil
            }
        }

        try super.init(node: node)
    }

    public override func serialize(context: DataContext) -> XMLSerializableElement {
        var element = super.serialize(context: context)
        if let cellType = cellType {
            element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
        }
        return element
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        guard let cellType = cellType else {
            throw LiveUIError(message: "cell for PlainTableView was not defined.")
        }
        let createCell = try context.componentInstantiation(named: cellType)
        let exampleCount = ToolingProperties.plainTableView.exampleCount.get(from: self.toolingProperties) ?? 5
        let tableView = Hyperdrive.PlainTableView<CellWrapper>(options: [], cellFactory: CellWrapper(wrapped: createCell()))
            .with(state: .items(Array(repeating: (), count: exampleCount)))

        tableView.tableView.rowHeight = UITableView.automaticDimension

        return tableView
    }
    #endif
}

public class PlainTableViewProperites: PropertyContainer {
    public let tableViewProperties: TableViewProperties
    public let emptyLabelProperties: LabelProperties
    public let loadingIndicatorProperties: ActivityIndicatorProperties

    public required init(configuration: Configuration) {
        tableViewProperties = configuration.namespaced(in: "tableView", TableViewProperties.self)
        emptyLabelProperties = configuration.namespaced(in: "emptyLabel", LabelProperties.self)
        loadingIndicatorProperties = configuration.namespaced(in: "loadingIndicator", ActivityIndicatorProperties.self)

        super.init(configuration: configuration)
    }
}

public class PlainTableViewToolingProperties: PropertyContainer {
    public let exampleCount: ValuePropertyDescription<Int>

    public required init(configuration: Configuration) {
        exampleCount = configuration.property(name: "tools:exampleCount")

        super.init(configuration: configuration)
    }
}

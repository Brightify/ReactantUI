//
//  HeaderTableView.swift
//  ReactantUI
//
//  Created by Matous Hybl on 06/09/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
    import UIKit
    import Reactant
    import RxDataSources
#endif

public class HeaderTableView: View, ComponentDefinitionContainer {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.headerTableView.allProperties
    }

    public override class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.headerTableView.allProperties
    }

    public var cellType: String?
    public var headerType: String?
    public var cellDefinition: ComponentDefinition?
    public var headerDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return (cellDefinition?.componentTypes ?? [cellType].compactMap { $0 }) + (headerDefinition?.componentTypes ?? [headerType].compactMap { $0 })
    }

    public var isAnonymous: Bool {
        return (cellDefinition?.isAnonymous ?? false) || (headerDefinition?.isAnonymous ?? false)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return (cellDefinition?.componentDefinitions ?? []) + (headerDefinition?.componentDefinitions ?? [])
    }

    public override class var parentModuleImport: String {
        return "Reactant"
    }

    public class override func runtimeType() -> String {
        return "ReactantTableView"
    }

    public override func initialization() -> String {
        guard let headerType = headerType, let cellType = cellType else {
            return "Initialization should never happen as the view was referenced via field."
        }
        return "HeaderTableView<\(headerType), \(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        if let field = node.value(ofAttribute: "field") as String?, !field.isEmpty {
            cellType = nil
            headerType = nil
            cellDefinition = nil
            headerDefinition = nil
        } else {
            guard let cellType = node.value(ofAttribute: "cell") as String? else {
                throw TokenizationError(message: "cell for HeaderTableView was not defined.")
            }
            self.cellType = cellType

            guard let headerType = node.value(ofAttribute: "header") as String? else {
                throw TokenizationError(message: "header for HeaderTableView was not defined.")
            }
            self.headerType = headerType

            if let cellElement = try node.singleOrNoElement(named: "cell") {
                cellDefinition = try ComponentDefinition(node: cellElement, type: cellType)
            } else {
                cellDefinition = nil
            }

            if let headerElement = try node.singleOrNoElement(named: "header") {
                headerDefinition = try ComponentDefinition(node: headerElement, type: headerType)
            } else {
                headerDefinition = nil
            }
        }

        try super.init(node: node)
    }

    public override func serialize(context: DataContext) -> XMLSerializableElement {
        var element = super.serialize(context: context)
        if let headerType = headerType, let cellType = cellType {
            element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
            element.attributes.append(XMLSerializableAttribute(name: "header", value: headerType))
        }

        // FIXME serialize anonymous cell and header
        return element
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        guard let cellType = cellType, let headerType = headerType else {
            throw LiveUIError(message: "cell or header for HeaderTableView was not defined.")
        }
        let createCell = try context.componentInstantiation(named: cellType)
        let createHeader = try context.componentInstantiation(named: headerType)
        let sectionCount = ToolingProperties.headerTableView.sectionCount.get(from: self.toolingProperties) ?? 5
        let itemCount = ToolingProperties.headerTableView.itemCount.get(from: self.toolingProperties) ?? 5
        let tableView = Reactant.HeaderTableView<CellWrapper, CellWrapper>(
            cellFactory: {
                CellWrapper(wrapped: createCell())
            },
            headerFactory: {
                CellWrapper(wrapped: createHeader())
            },
            options: [.reloadable, .deselectsAutomatically])
            .with(state: .items(Array(repeating: SectionModel(model: (), items: Array(repeating: (), count: itemCount)), count: sectionCount)))

        tableView.tableView.rowHeight = UITableView.automaticDimension
        tableView.tableView.sectionHeaderHeight = UITableView.automaticDimension

        return tableView
    }
    #endif
}

public class HeaderTableViewProperites: PropertyContainer {
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


public class HeaderTableViewToolingProperties: PropertyContainer {
    public let sectionCount: ValuePropertyDescription<Int>
    public let itemCount: ValuePropertyDescription<Int>

    public required init(configuration: Configuration) {
        sectionCount = configuration.property(name: "tools:sectionCount")
        itemCount = configuration.property(name: "tools:exampleCount")

        super.init(configuration: configuration)
    }
}

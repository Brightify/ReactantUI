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

    public var cellType: String
    public var headerType: String
    public var cellDefinition: ComponentDefinition?
    public var headerDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return (cellDefinition?.componentTypes ?? [cellType]) + (headerDefinition?.componentTypes ?? [headerType])
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
        return "HeaderTableView<\(headerType), \(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        cellType = try node.value(ofAttribute: "cell")
        headerType = try node.value(ofAttribute: "header")
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

        try super.init(node: node)
    }

    public override func serialize() -> XMLSerializableElement {
        var element = super.serialize()
        element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
        element.attributes.append(XMLSerializableAttribute(name: "header", value: headerType))

        // FIXME serialize anonymous cell and header
        return element
    }

    #if canImport(UIKit)
    public override func initialize() throws -> UIView {
        let createCell = try ReactantLiveUIManager.shared.componentInstantiation(named: cellType)
        let createHeader = try ReactantLiveUIManager.shared.componentInstantiation(named: headerType)
        let sectionCount = ToolingProperties.headerTableView.sectionCount.get(from: self.toolingProperties) ?? 5
        let itemCount = ToolingProperties.headerTableView.itemCount.get(from: self.toolingProperties) ?? 5
        let tableView = Reactant.HeaderTableView<CellWrapper, CellWrapper>(
            cellFactory: {
                CellWrapper(wrapped: createCell())
            },
            headerFactory: {
                CellWrapper(wrapped: createHeader())
            })
            .with(state: .items(Array(repeating: SectionModel(model: (), items: Array(repeating: (), count: itemCount)), count: sectionCount)))

        tableView.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableView.sectionHeaderHeight = UITableViewAutomaticDimension

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

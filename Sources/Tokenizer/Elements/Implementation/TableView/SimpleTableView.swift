//
//  SimpleTableView.swift
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

public class SimpleTableView: View, ComponentDefinitionContainer {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.simpleTableView.allProperties
    }

    public override class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.simpleTableView.allProperties
    }

    public var cellType: String
    public var headerType: String
    public var footerType: String
    public var cellDefinition: ComponentDefinition?
    public var headerDefinition: ComponentDefinition?
    public var footerDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return (cellDefinition?.componentTypes ?? [cellType])
            + (headerDefinition?.componentTypes ?? [headerType])
            + (footerDefinition?.componentTypes ?? [footerType])
    }

    public var isAnonymous: Bool {
        return (cellDefinition?.isAnonymous ?? false)
            || (headerDefinition?.isAnonymous ?? false)
            || (footerDefinition?.isAnonymous ?? false)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return (cellDefinition?.componentDefinitions ?? [])
            + (headerDefinition?.componentDefinitions ?? [])
            + (footerDefinition?.componentDefinitions ?? [])
    }

    public class override func runtimeType() -> String {
        return "ReactantTableView"
    }

    public override class var parentModuleImport: String {
        return "Reactant"
    }

    public override func initialization() -> String {
        return "SimpleTableView<\(headerType), \(cellType), \(footerType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        cellType = try node.value(ofAttribute: "cell")
        headerType = try node.value(ofAttribute: "header")
        footerType = try node.value(ofAttribute: "footer")
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

        if let footerElement = try node.singleOrNoElement(named: "footer") {
            footerDefinition = try ComponentDefinition(node: footerElement, type: footerType)
        } else {
            footerDefinition = nil
        }

        try super.init(node: node)
    }

    public override func serialize(context: DataContext) -> XMLSerializableElement {
        var element = super.serialize(context: context)
        element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
        element.attributes.append(XMLSerializableAttribute(name: "header", value: headerType))
        element.attributes.append(XMLSerializableAttribute(name: "footer", value: footerType))

        // FIXME serialize anonymous cells
        return element
    }

    #if canImport(UIKit)
    public override func initialize() throws -> UIView {
        let createCell = try ReactantLiveUIManager.shared.componentInstantiation(named: cellType)
        let createHeader = try ReactantLiveUIManager.shared.componentInstantiation(named: headerType)
        let createFooter = try ReactantLiveUIManager.shared.componentInstantiation(named: footerType)
        let sectionCount = ToolingProperties.headerTableView.sectionCount.get(from: self.toolingProperties) ?? 5
        let itemCount = ToolingProperties.headerTableView.itemCount.get(from: self.toolingProperties) ?? 5
        let tableView = Reactant.SimpleTableView<CellWrapper, CellWrapper, CellWrapper>(
            cellFactory: {
                CellWrapper(wrapped: createCell())
            },
            headerFactory: {
                CellWrapper(wrapped: createHeader())
            },
            footerFactory: {
                CellWrapper(wrapped: createFooter())
            })
            .with(state: .items(Array(repeating: SectionModel(model: (header: (), footer: ()),
                                                              items: Array(repeating: (), count: itemCount)),
                                                              count: sectionCount)))

        tableView.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.tableView.sectionFooterHeight = UITableViewAutomaticDimension

        return tableView
    }
    #endif
}

public class SimpleTableViewProperites: PropertyContainer {
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


public class SimpleTableViewToolingProperties: PropertyContainer {
    public let sectionCount: ValuePropertyDescription<Int>
    public let itemCount: ValuePropertyDescription<Int>

    public required init(configuration: Configuration) {
        sectionCount = configuration.property(name: "tools:sectionCount")
        itemCount = configuration.property(name: "tools:exampleCount")

        super.init(configuration: configuration)
    }
}

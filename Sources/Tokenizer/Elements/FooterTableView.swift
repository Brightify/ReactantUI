//
//  FooterTableView.swift
//  ReactantUI
//
//  Created by Matous Hybl on 06/09/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
    import Reactant
    import RxDataSources
#endif

public class FooterTableView: View, ComponentDefinitionContainer {
    override class var availableProperties: [PropertyDescription] {
        return Properties.view.allProperties
    }

    override class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.footerTableView.allProperties
    }

    public var cellType: String
    public var footerType: String
    public var cellDefinition: ComponentDefinition?
    public var footerDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return (cellDefinition?.componentTypes ?? [cellType]) + (footerDefinition?.componentTypes ?? [footerType])
    }

    public var isAnonymous: Bool {
        return (cellDefinition?.isAnonymous ?? false) || (footerDefinition?.isAnonymous ?? false)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return (cellDefinition?.componentDefinitions ?? []) + (footerDefinition?.componentDefinitions ?? [])
    }

    public class override var runtimeType: String {
        return "UITableView"
    }

    public override var initialization: String {
        return "FooterTableView<\(footerType), \(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        cellType = try node.value(ofAttribute: "cell")
        footerType = try node.value(ofAttribute: "footer")
        if let cellElement = try node.singleOrNoElement(named: "cell") {
            cellDefinition = try ComponentDefinition(node: cellElement, type: cellType)
        } else {
            cellDefinition = nil
        }

        if let footerElement = try node.singleOrNoElement(named: "footer") {
            footerDefinition = try ComponentDefinition(node: footerElement, type: footerType)
        } else {
            footerDefinition = nil
        }

        try super.init(node: node)
    }

    public override func serialize() -> MagicElement {
        var element = super.serialize()
        element.attributes.append(MagicAttribute(name: "cell", value: cellType))
        element.attributes.append(MagicAttribute(name: "footer", value: footerType))

        // FIXME serialize footer
        return element
    }

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        let createCell = try ReactantLiveUIManager.shared.componentInstantiation(named: cellType)
        let createFooter = try ReactantLiveUIManager.shared.componentInstantiation(named: footerType)
        let sectionCount = ToolingProperties.footerTableView.sectionCount.get(from: self.toolingProperties) ?? 5
        let itemCount = ToolingProperties.footerTableView.itemCount.get(from: self.toolingProperties) ?? 5
        let tableView = Reactant.FooterTableView<CellHack, CellHack>(
            cellFactory: {
                CellHack(wrapped: createCell())
            },
            footerFactory: {
                CellHack(wrapped: createFooter())
            })
            .with(state: .items(Array(repeating: SectionModel(model: (), items: Array(repeating: (), count: itemCount)), count: sectionCount)))

        tableView.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableView.sectionFooterHeight = UITableViewAutomaticDimension

        return tableView
    }

    public final class CellHack: ViewBase<Void, Void> {
        private let wrapped: UIView

        public init(wrapped: UIView) {
            self.wrapped = wrapped
            super.init()
        }

        public override func loadView() {
            children(
                wrapped
            )
        }

        public override func setupConstraints() {
            wrapped.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    #endif
}

public class FooterTableViewToolingProperties: PropertyContainer {
    public let sectionCount: ValuePropertyDescription<Int>
    public let itemCount: ValuePropertyDescription<Int>

    public required init(configuration: Configuration) {
        sectionCount = configuration.property(name: "tools:sectionCount")
        itemCount = configuration.property(name: "tools:exampleCount")

        super.init(configuration: configuration)
    }
}

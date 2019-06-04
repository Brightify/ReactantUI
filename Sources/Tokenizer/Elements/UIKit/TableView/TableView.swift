//
//  TableView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
#endif

public class TableView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.tableView.allProperties
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UITableView()
    }
    #endif
}

public enum RowHeight: AttributeSupportedPropertyType {
    private static let automaticIdentifier = "auto"

    case value(Float)
    case automatic

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        switch self {
        case .value(let value):
            return value.generate(context: context.child(for: value))
        case .automatic:
            return .constant("UITableView.automaticDimension")
        }
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        switch self {
        case .value(let value):
            return value.dematerialize(context: context.child(for: value))
        case .automatic:
            return RowHeight.automaticIdentifier
        }
    }
    #endif

    public static func materialize(from value: String) throws -> RowHeight {
        if value == automaticIdentifier {
            return .automatic
        } else {
            return try .value(Float.materialize(from: value))
        }
    }

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .value(let value):
            return value
        case .automatic:
            return UITableView.automaticDimension
        }
    }
    #endif

    public static var runtimeType: String = "CGFloat"

    public static var xsdType: XSDType {
        let valueType = Float.xsdType
        let automaticType = XSDType.enumeration(EnumerationXSDType(name: "rowHeightAuto", base: .string, values: [automaticIdentifier]))

        return XSDType.union(UnionXSDType(name: "rowHeight", memberTypes: [valueType, automaticType]))
    }
}

public class TableViewProperties: ViewProperties {
    public let rowHeight: AssignablePropertyDescription<RowHeight>
    public let separatorStyle: AssignablePropertyDescription<TableViewCellSeparatorStyle>
    public let separatorColor: AssignablePropertyDescription<UIColorPropertyType>
    public let separatorEffect: AssignablePropertyDescription<VisualEffect?>
    public let separatorInset: AssignablePropertyDescription<EdgeInsets>
    public let separatorInsetReference: AssignablePropertyDescription<TableViewCellSeparatorInsetReference>
    public let cellLayoutMarginsFollowReadableWidth: AssignablePropertyDescription<Bool>
    public let sectionHeaderHeight: AssignablePropertyDescription<Double>
    public let sectionFooterHeight: AssignablePropertyDescription<Double>
    public let estimatedRowHeight: AssignablePropertyDescription<Double>
    public let estimatedSectionHeaderHeight: AssignablePropertyDescription<Double>
    public let estimatedSectionFooterHeight: AssignablePropertyDescription<Double>
    public let allowsSelection: AssignablePropertyDescription<Bool>
    public let allowsMultipleSelection: AssignablePropertyDescription<Bool>
    public let allowsSelectionDuringEditing: AssignablePropertyDescription<Bool>
    public let allowsMultipleSelectionDuringEditing: AssignablePropertyDescription<Bool>
    public let dragInteractionEnabled: AssignablePropertyDescription<Bool>
    public let isEditing: AssignablePropertyDescription<Bool>
    public let sectionIndexMinimumDisplayRowCount: AssignablePropertyDescription<Int>
    public let sectionIndexColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let sectionIndexBackgroundColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let sectionIndexTrackingBackgroundColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let remembersLastFocusedIndexPath: AssignablePropertyDescription<Bool>
    public let insetsContentViewsToSafeArea: AssignablePropertyDescription<Bool>

    public required init(configuration: Configuration) {
        rowHeight = configuration.property(name: "rowHeight", defaultValue: .automatic)
        separatorStyle = configuration.property(name: "separatorStyle", defaultValue: .singleLine)
        separatorColor = configuration.property(name: "separatorColor", defaultValue: .color(.named("gray")))
        separatorEffect = configuration.property(name: "separatorEffect")
        separatorInset = configuration.property(name: "separatorInset", defaultValue: EdgeInsets(left: 15))
        separatorInsetReference = configuration.property(name: "separatorInsetReference", defaultValue: .fromCellEdges)
        cellLayoutMarginsFollowReadableWidth = configuration.property(name: "cellLayoutMarginsFollowReadableWidth")
        sectionHeaderHeight = configuration.property(name: "sectionHeaderHeight", defaultValue: -1)
        sectionFooterHeight = configuration.property(name: "sectionFooterHeight", defaultValue: -1)
        estimatedRowHeight = configuration.property(name: "estimatedRowHeight", defaultValue: -1)
        estimatedSectionHeaderHeight = configuration.property(name: "estimatedSectionHeaderHeight", defaultValue: -1)
        estimatedSectionFooterHeight = configuration.property(name: "estimatedSectionFooterHeight", defaultValue: -1)
        allowsSelection = configuration.property(name: "allowsSelection", defaultValue: true)
        allowsMultipleSelection = configuration.property(name: "allowsMultipleSelection")
        allowsSelectionDuringEditing = configuration.property(name: "allowsSelectionDuringEditing")
        allowsMultipleSelectionDuringEditing = configuration.property(name: "allowsMultipleSelectionDuringEditing")
        dragInteractionEnabled = configuration.property(name: "dragInteractionEnabled", defaultValue: true)
        isEditing = configuration.property(name: "isEditing")
        sectionIndexMinimumDisplayRowCount = configuration.property(name: "sectionIndexMinimumDisplayRowCount")
        sectionIndexColor = configuration.property(name: "sectionIndexColor")
        sectionIndexBackgroundColor = configuration.property(name: "sectionIndexBackgroundColor")
        sectionIndexTrackingBackgroundColor = configuration.property(name: "sectionIndexTrackingBackgroundColor")
        remembersLastFocusedIndexPath = configuration.property(name: "remembersLastFocusedIndexPath")
        insetsContentViewsToSafeArea = configuration.property(name: "insetsContentViewsToSafeArea", defaultValue: true)

        super.init(configuration: configuration)
    }
}

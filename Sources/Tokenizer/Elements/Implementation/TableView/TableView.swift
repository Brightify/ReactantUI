//
//  TableView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public class TableView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.tableView.allProperties
    }

    public override class func runtimeType() -> String {
        return "UITableView"
    }

    public override func initialization() -> String {
        return "UITableView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UITableView()
    }
    #endif
}

public class TableViewProperties: ViewProperties {
    public let rowHeight: AssignablePropertyDescription<Float>
    public let separatorStyle: AssignablePropertyDescription<TableViewCellSeparatorStyle>
    public let separatorColor: AssignablePropertyDescription<UIColorPropertyType>
    public let separatorEffect: AssignablePropertyDescription<VisualEffect>
    public let separatorInset: AssignablePropertyDescription<EdgeInsets>
    public let separatorInsetReference: AssignablePropertyDescription<TableViewCellSeparatorInsetReference>
    public let cellLayoutMarginsFollowReadableWidth: AssignablePropertyDescription<Bool>
    public let sectionHeaderHeight: AssignablePropertyDescription<Float>
    public let sectionFooterHeight: AssignablePropertyDescription<Float>
    public let estimatedRowHeight: AssignablePropertyDescription<Float>
    public let estimatedSectionHeaderHeight: AssignablePropertyDescription<Float>
    public let estimatedSectionFooterHeight: AssignablePropertyDescription<Float>
    public let allowsSelection: AssignablePropertyDescription<Bool>
    public let allowsMultipleSelection: AssignablePropertyDescription<Bool>
    public let allowsSelectionDuringEditing: AssignablePropertyDescription<Bool>
    public let allowsMultipleSelectionDuringEditing: AssignablePropertyDescription<Bool>
    public let dragInteractionEnabled: AssignablePropertyDescription<Bool>
    public let isEditing: AssignablePropertyDescription<Bool>
    public let sectionIndexMinimumDisplayRowCount: AssignablePropertyDescription<Int>
    public let sectionIndexColor: AssignablePropertyDescription<UIColorPropertyType>
    public let sectionIndexBackgroundColor: AssignablePropertyDescription<UIColorPropertyType>
    public let sectionIndexTrackingBackgroundColor: AssignablePropertyDescription<UIColorPropertyType>
    public let remembersLastFocusedIndexPath: AssignablePropertyDescription<Bool>
    public let insetsContentViewsToSafeArea: AssignablePropertyDescription<Bool>

    public required init(configuration: Configuration) {
        rowHeight = configuration.property(name: "rowHeight")
        separatorStyle = configuration.property(name: "separatorStyle")
        separatorColor = configuration.property(name: "separatorColor")
        separatorEffect = configuration.property(name: "separatorEffect")
        separatorInset = configuration.property(name: "separatorInset")
        separatorInsetReference = configuration.property(name: "separatorInsetReference")
        cellLayoutMarginsFollowReadableWidth = configuration.property(name: "cellLayoutMarginsFollowReadableWidth")
        sectionHeaderHeight = configuration.property(name: "sectionHeaderHeight")
        sectionFooterHeight = configuration.property(name: "sectionFooterHeight")
        estimatedRowHeight = configuration.property(name: "estimatedRowHeight")
        estimatedSectionHeaderHeight = configuration.property(name: "estimatedSectionHeaderHeight")
        estimatedSectionFooterHeight = configuration.property(name: "estimatedSectionFooterHeight")
        allowsSelection = configuration.property(name: "allowsSelection")
        allowsMultipleSelection = configuration.property(name: "allowsMultipleSelection")
        allowsSelectionDuringEditing = configuration.property(name: "allowsSelectionDuringEditing")
        allowsMultipleSelectionDuringEditing = configuration.property(name: "allowsMultipleSelectionDuringEditing")
        dragInteractionEnabled = configuration.property(name: "dragInteractionEnabled")
        isEditing = configuration.property(name: "isEditing")
        sectionIndexMinimumDisplayRowCount = configuration.property(name: "sectionIndexMinimumDisplayRowCount")
        sectionIndexColor = configuration.property(name: "sectionIndexColor")
        sectionIndexBackgroundColor = configuration.property(name: "sectionIndexBackgroundColor")
        sectionIndexTrackingBackgroundColor = configuration.property(name: "sectionIndexTrackingBackgroundColor")
        remembersLastFocusedIndexPath = configuration.property(name: "remembersLastFocusedIndexPath")
        insetsContentViewsToSafeArea = configuration.property(name: "insetsContentViewsToSafeArea")

        super.init(configuration: configuration)
    }
}

//
//  SearchBar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class SearchBar: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.searchBar.allProperties
    }

    public class override func runtimeType() throws -> String {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: SearchBar.self)
        #else
        return "UISearchBar"
        #endif
    }

    #if canImport(UIKit)
    public override func initialize() throws -> UIView {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: SearchBar.self)
        #else
            return UISearchBar()
        #endif
    }
    #endif
}

public class SearchBarProperties: ViewProperties {
    public let text: AssignablePropertyDescription<TransformedText>
    public let placeholder: AssignablePropertyDescription<TransformedText>
    public let prompt: AssignablePropertyDescription<TransformedText>
    public let barTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let barStyle: AssignablePropertyDescription<BarStyle>
    public let searchBarStyle: AssignablePropertyDescription<SearchBarStyle>
    public let isTranslucent: AssignablePropertyDescription<Bool>
    public let showsBookmarkButton: AssignablePropertyDescription<Bool>
    public let showsCancelButton: AssignablePropertyDescription<Bool>
    public let showsSearchResultsButton: AssignablePropertyDescription<Bool>
    public let isSearchResultsButtonSelected: AssignablePropertyDescription<Bool>
    public let selectedScopeButtonIndex: AssignablePropertyDescription<Int>
    public let showsScopeBar: AssignablePropertyDescription<Bool>
    public let backgroundImage: AssignablePropertyDescription<Image>
    public let scopeBarBackgroundImage: AssignablePropertyDescription<Image>
    
    public required init(configuration: Configuration) {
        text = configuration.property(name: "text")
        placeholder = configuration.property(name: "placeholder")
        prompt = configuration.property(name: "prompt")
        barTintColor = configuration.property(name: "barTintColor")
        barStyle = configuration.property(name: "barStyle")
        searchBarStyle = configuration.property(name: "searchBarStyle")
        isTranslucent = configuration.property(name: "isTranslucent", key: "translucent")
        showsBookmarkButton = configuration.property(name: "showsBookmarkButton")
        showsCancelButton = configuration.property(name: "showsCancelButton")
        showsSearchResultsButton = configuration.property(name: "showsSearchResultsButton")
        isSearchResultsButtonSelected = configuration.property(name: "isSearchResultsButtonSelected", key: "searchResultsButtonSelected")
        selectedScopeButtonIndex = configuration.property(name: "selectedScopeButtonIndex")
        showsScopeBar = configuration.property(name: "showsScopeBar")
        backgroundImage = configuration.property(name: "backgroundImage")
        scopeBarBackgroundImage = configuration.property(name: "scopeBarBackgroundImage")
        
        super.init(configuration: configuration)
    }
}
    

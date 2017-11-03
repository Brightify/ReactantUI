//
//  KeyboardType.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 21/06/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum TextContentType: String, EnumPropertyType {
    public static let enumName = "UITextContentType"

    case none
    case URL
    case addressCity
    case addressCityAndState
    case addressState
    case countryName
    case creditCardNumber
    case emailAddress
    case familyName
    case fullStreetAddress
    case givenName
    case jobTitle
    case location
    case middleName
    case name
    case namePrefix
    case nameSuffix
    case nickname
    case organizationName
    case postalCode
    case streetAddressLine1
    case streetAddressLine2
    case sublocality
    case telephoneNumber
//    case username
//    case password
}

#if ReactantRuntime
    import UIKit

    extension TextContentType {

        public var runtimeValue: Any? {
            if #available(iOS 10.0, tvOS 10.0, *) {
                switch self {
                case .none:
                    return nil
                case .URL:
                    return UITextContentType(UITextContentType.URL.rawValue)
                case .addressCity:
                    return UITextContentType(UITextContentType.addressCity.rawValue)
                case .addressCityAndState:
                    return UITextContentType(UITextContentType.addressCityAndState.rawValue)
                case .addressState:
                    return UITextContentType(UITextContentType.addressState.rawValue)
                case .countryName:
                    return UITextContentType(UITextContentType.countryName.rawValue)
                case .creditCardNumber:
                    return UITextContentType(UITextContentType.creditCardNumber.rawValue)
                case .emailAddress:
                    return UITextContentType(UITextContentType.emailAddress.rawValue)
                case .familyName:
                    return UITextContentType(UITextContentType.familyName.rawValue)
                case .fullStreetAddress:
                    return UITextContentType(UITextContentType.fullStreetAddress.rawValue)
                case .givenName:
                    return UITextContentType(UITextContentType.givenName.rawValue)
                case .jobTitle:
                    return UITextContentType(UITextContentType.jobTitle.rawValue)
                case .location:
                    return UITextContentType(UITextContentType.location.rawValue)
                case .middleName:
                    return UITextContentType(UITextContentType.middleName.rawValue)
                case .name:
                    return UITextContentType(UITextContentType.name.rawValue)
                case .namePrefix:
                    return UITextContentType(UITextContentType.namePrefix.rawValue)
                case .nameSuffix:
                    return UITextContentType(UITextContentType.nameSuffix.rawValue)
                case .nickname:
                    return UITextContentType(UITextContentType.nickname.rawValue)
                case .organizationName:
                    return UITextContentType(UITextContentType.organizationName.rawValue)
                case .postalCode:
                    return UITextContentType(UITextContentType.postalCode.rawValue)
                case .streetAddressLine1:
                    return UITextContentType(UITextContentType.streetAddressLine1.rawValue)
                case .streetAddressLine2:
                    return UITextContentType(UITextContentType.streetAddressLine2.rawValue)
                case .sublocality:
                    return UITextContentType(UITextContentType.sublocality.rawValue)
                case .telephoneNumber:
                    return UITextContentType(UITextContentType.telephoneNumber.rawValue)
//                case .username:
//                    if #available(iOS 11.0, *) {
//                        return UITextContentType(UITextContentType.username.rawValue)
//                    } else {
//                        return nil
//                    }
//                case .password:
//                    if #available(iOS 11.0, *) {
//                        return UITextContentType(UITextContentType.password.rawValue)
//                    } else {
//                        return nil
//                    }
                }
            } else {
                return nil
            }
        }
    }
#endif

//
// SwiftGenKit
// Copyright (c) 2017 SwiftGen
// MIT Licence
//

import Foundation
import Kanna

extension InterfaceBuilder {
  struct ScenePlaceholder {
    let sceneID: String
    let storyboardName: String
    let referencedIdentifier: String?
  }
}

// MARK: - XML

private enum XML {
  static let idAttribute = "id"
  static let storyboardNameAttribute = "storyboardName"
  static let referencedIdentifierAttribute = "referencedIdentifier"
}

extension InterfaceBuilder.ScenePlaceholder {
  init(with object: Kanna.XMLElement, storyboard: String) {
    sceneID = object[XML.idAttribute] ?? ""
    storyboardName = object[XML.storyboardNameAttribute] ?? storyboard
    referencedIdentifier = object[XML.referencedIdentifierAttribute]
  }
}

// MARK: - Hashable

extension InterfaceBuilder.ScenePlaceholder: Equatable { }
func == (lhs: InterfaceBuilder.ScenePlaceholder, rhs: InterfaceBuilder.ScenePlaceholder) -> Bool {
  return lhs.sceneID == rhs.sceneID
}

extension InterfaceBuilder.ScenePlaceholder: Hashable {
  var hashValue: Int {
    return sceneID.hashValue
  }
}

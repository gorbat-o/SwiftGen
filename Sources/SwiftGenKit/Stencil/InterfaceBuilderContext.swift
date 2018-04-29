//
// SwiftGenKit
// Copyright (c) 2017 SwiftGen
// MIT Licence
//

import Foundation

extension Dictionary {
  func merging(_ other: [Key: Value]) -> [Key: Value] {
    return merging(other) { current, _ in
      current
    }
  }
}

/*
 - `modules`    : `Array<String>` — List of modules used by scenes and segues — typically used for "import" statements
 - `platform`   : `String` — Name of the target platform (only available if all storyboards target the same platform)
 - `storyboards`: `Array` — List of storyboards
    - `name`: `String` — Name of the storyboard
    - `platform`: `String` — Name of the target platform (iOS, macOS, tvOS, watchOS)
    - `initialScene`: `Dictionary` — Same structure as scenes item (absent if not specified)
    - `scenes`: `Array` - List of scenes
       - `identifier` : `String` — The scene identifier
       - `customClass`: `String` — The custom class of the scene (absent if generic UIViewController/NSViewController)
       - `customModule`: `String` — The custom module of the scene (absent if no custom class)
       - `baseType`: `String` — The base class type of the scene if not custom (absent if class is a custom class).
          Possible values include 'ViewController', 'NavigationController', 'TableViewController'…
       - `type`: `String` — The fully qualified type of the scene (custom class, or base type prefixed with platform
          class prefix such as `UI`)
       - `module`: `String` — The module of the scene, could be the value of `customModule`, or of an internal module
          such as GLKit depending on the base type (can be empty)
    - `segues`: `Array` - List of segues
       - `identifier`: `String` — The segue identifier
       - `kind`: `String` — The kind of the segue (show, presentation, embed, relationship, custom, ...)
       - `customClass`: `String` — The custom class of the segue (absent if generic UIStoryboardSegue)
       - `customModule`: `String` — The custom module of the segue (absent if no custom segue class)
       - `type`: `String` — The fully qualified type of the segue (custom class, or base type prefixed with platform
          class prefix such as `UI`)
       - `module`: `String` — The module of the segue, could be the value of `customModule`, or of an internal module
          such as GLKit depending on the base type (can be empty)
*/
extension InterfaceBuilder.Parser {
  public func stencilContext() -> [String: Any] {
    let storyboards = self.storyboards
      .sorted { lhs, rhs in lhs.name < rhs.name }
      .map(map(storyboard:))

    return [
      "modules": modules.sorted(),
      "storyboards": storyboards,
      "customSceneTypes": customSceneTypes
        .map { map(customType: $0) },
      "platform": platform ?? ""
    ]
  }

  private func map(storyboard: InterfaceBuilder.Storyboard) -> [String: Any] {
    var result: [String: Any] = [
      "name": storyboard.name,
      "scenes": Array(storyboard.scenes)
        .filter { !$0.identifier.isEmpty }
        .sorted { $0.identifier < $1.identifier }
        .map { map(scene: $0) },
      "segues": Array(storyboard.segues)
        .filter { !$0.identifier.isEmpty }
        .sorted { $0.identifier < $1.identifier }
        .map { map(segue: $0, in: storyboard) },
      "platform": storyboard.platform.name
    ]

    if let scene = storyboard.initialScene {
      result["initialScene"] = map(scene: scene)
    }

    return result
  }

  private func map(scene: InterfaceBuilder.Scene) -> [String: Any] {
    let result = map(swiftType: scene)

    if let customClass = scene.customClass {
      return result.merging([
        "identifier": scene.identifier,
        "customClass": customClass,
        "customModule": scene.customModule ?? ""
      ])
    } else {
      return result.merging([
        "identifier": scene.identifier,
        "baseType": scene.tag.uppercasedFirst()
      ])
    }
  }

  private func map(segue: InterfaceBuilder.Segue, in storyboard: InterfaceBuilder.Storyboard) -> [String: Any] {
    let scene = destination(for: segue.destination, in: storyboard)
    return map(segue: segue, destination: scene)
  }

  private func map(segue: InterfaceBuilder.Segue, destination: InterfaceBuilder.Scene?) -> [String: Any] {
    var result = map(swiftType: segue).merging([
      "identifier": segue.identifier,
      "kind": segue.kind,
      "customClass": segue.customClass ?? "",
      "customModule": segue.customModule ?? ""
    ])

    if let destination = destination {
      result["destination"] = map(scene: destination)
    }

    return result
  }

  private func map(customType: InterfaceBuilder.CustomType) -> [String: Any] {
    return map(swiftType: customType).merging([
      "segues": customType.segues
        .sorted { $0.identifier < $1.identifier }
        .map { segue -> Any in
          let destination = customType.destinations[segue]
          return map(segue: segue, destination: destination)
        }
    ])
  }

  private func map(swiftType: InterfaceBuilderSwiftType) -> [String: Any] {
    return [
      "type": swiftType.type,
      "module": swiftType.module ?? ""
    ]
  }
}

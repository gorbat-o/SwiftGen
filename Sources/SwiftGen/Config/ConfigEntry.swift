//
//  ConfigEntry.swift
//  swiftgen
//
//  Created by Olivier Halligon on 21/10/2017.
//  Copyright © 2017 AliSoftware. All rights reserved.
//

import PathKit

// MARK: - Config.Entry

extension Config {
  struct Entry {
    enum Keys {
      static let inputs = "inputs"
      static let outputs = "outputs"

      // Legacy: remove this once we stop supporting the output key at subcommand level
      static let output = "output"
      // Legacy: remove this once we sto supporting the old paths key (replaced by inputs)
      static let paths = "paths"
    }

    var inputs: [Path]
    var outputs: [Output]

    mutating func makeRelativeTo(inputDir: Path?, outputDir: Path?) {
      if let inputDir = inputDir {
        self.inputs = self.inputs.map { $0.isRelative ? inputDir + $0 : $0 }
      }
      self.outputs = self.outputs.map {
        var output = $0
        output.makeRelativeTo(outputDir: outputDir)
        return output
      }
    }
  }
}

extension Config.Entry {
  init(yaml: [String: Any]) throws {
    guard let inputs = yaml[Keys.inputs] ?? yaml[Keys.paths] else {
      throw Config.Error.missingEntry(key: Keys.inputs)
    }
    self.inputs = try Config.Entry.parseValueOrArray(yaml: inputs, key: Keys.inputs) {
      Path($0)
    }

    if let outputs = yaml[Keys.outputs] {
      do {
        self.outputs = try Config.Entry.Output.parseCommandOutput(yaml: outputs)
      } catch let error as Config.Error {
        throw error.withKeyPrefixed(by: Keys.outputs)
      }
    } else if yaml[Keys.output] != nil {
      // Legacy: remove this once we stop supporting the output key at subcommand level
      // The config still contains the old style where all properties command properties
      // are at the same level
      self.outputs = try Config.Entry.Output.parseCommandOutput(yaml: yaml)
    } else {
      throw Config.Error.missingEntry(key: Keys.outputs)
    }
  }

  static func parseCommandEntry(yaml: Any) throws -> [Config.Entry] {
    return try Config.Entry.parseValueOrArray(yaml: yaml) {
      return try Config.Entry(yaml: $0)
    }
  }

  static func getOptionalField<T>(yaml: [String: Any], key: String) throws -> T? {
    guard let value = yaml[key] else {
      return nil
    }
    guard let typedValue = value as? T else {
      throw Config.Error.wrongType(key: key, expected: String(describing: T.self), got: type(of: value))
    }
    return typedValue
  }

  static func parseValueOrArray<T, U>(yaml: Any, key: String? = nil, parseValue: (T) throws -> U) throws -> [U] {
    if let value = yaml as? T {
      return [try parseValue(value)]
    } else if let value = yaml as? [T] {
      return try value.map { try parseValue($0) }
    } else {
      throw Config.Error.wrongType(key: key, expected: "\(T.self) or Array of \(T.self)", got: type(of: yaml))
    }
  }
}

/// Convert to CommandLine-equivalent string (for verbose mode, printing linting info, …)
///
extension Config.Entry {
  func commandLine(forCommand cmd: String) -> [String] {
    return outputs.map {
      $0.commandLine(forCommand: cmd, inputs: inputs)
    }
  }
}

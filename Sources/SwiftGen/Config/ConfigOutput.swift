//
//  ConfigOutput.swift
//  swiftgen
//
//  Created by David Jennes on 05/05/2018.
//  Copyright © 2018 AliSoftware. All rights reserved.
//

import PathKit
import enum StencilSwiftKit.Parameters

// MARK: - Config.Entry.Output

extension Config.Entry {
  struct Output {
    enum Keys {
      static let output = "output"
      static let params = "params"
      static let templateName = "templateName"
      static let templatePath = "templatePath"
    }

    var output: Path
    var parameters: [String: Any]
    var template: TemplateRef

    mutating func makeRelativeTo(outputDir: Path?) {
      if let outputDir = outputDir, self.output.isRelative {
        self.output = outputDir + self.output
      }
    }
  }
}

extension Config.Entry.Output {
  init(yaml: [String: Any], logger: (LogLevel, String) -> Void) throws {
    guard let output: String = try Config.Entry.getOptionalField(yaml: yaml, key: Keys.output) else {
      throw Config.Error.missingEntry(key: Keys.output)
    }
    self.output = Path(output)

    self.parameters = try Config.Entry.getOptionalField(yaml: yaml, key: Keys.params) ?? [:]

    let templateName: String = try Config.Entry.getOptionalField(yaml: yaml, key: Keys.templateName) ?? ""
    let templatePath: String = try Config.Entry.getOptionalField(yaml: yaml, key: Keys.templatePath) ?? ""
    self.template = try TemplateRef(templateShortName: templateName, templateFullPath: templatePath)
  }

  static func parseCommandOutput(yaml: Any, logger: (LogLevel, String) -> Void) throws -> [Config.Entry.Output] {
    return try Config.Entry.parseValueOrArray(yaml: yaml) {
      return try Config.Entry.Output(yaml: $0, logger: logger)
    }
  }
}

/// Convert to CommandLine-equivalent string (for verbose mode, printing linting info, …)
///
extension Config.Entry.Output {
  func commandLine(forCommand cmd: String, inputs: [Path]) -> String {
    let tplFlag: String = {
      switch self.template {
      case .name(let name): return "-t \(name)"
      case .path(let path): return "-p \(path.string)"
      }
    }()
    let params = Parameters.flatten(dictionary: self.parameters)

    return [
      "swiftgen",
      cmd,
      tplFlag,
      params.map { "--param \($0)" }.joined(separator: " "),
      "-o \(self.output)",
      inputs.map { $0.string }.joined(separator: " ")
    ].filter { !$0.isEmpty }.joined(separator: " ")
  }
}

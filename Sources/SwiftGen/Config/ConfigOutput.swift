//
//  ConfigOutput.swift
//  swiftgen
//
//  Created by David Jennes on 05/05/2018.
//  Copyright © 2018 AliSoftware. All rights reserved.
//

import PathKit

// MARK: - Config.Entry.Output

extension Config.Entry {
  struct Output {
    enum Keys {
      static let templateName = "templateName"
      static let templatePath = "templatePath"
      static let output = "output"
    }

    var output: Path
    var template: TemplateRef

    mutating func makeRelativeTo(outputDir: Path?) {
      if let outputDir = outputDir, self.output.isRelative {
        self.output = outputDir + self.output
      }
    }
  }
}

extension Config.Entry.Output {
  init(yaml: [String: Any]) throws {
    let templateName: String = try Config.Entry.getOptionalField(yaml: yaml, key: Keys.templateName) ?? ""
    let templatePath: String = try Config.Entry.getOptionalField(yaml: yaml, key: Keys.templatePath) ?? ""
    self.template = try TemplateRef(templateShortName: templateName, templateFullPath: templatePath)

    guard let output: String = try Config.Entry.getOptionalField(yaml: yaml, key: Keys.output) else {
      throw Config.Error.missingEntry(key: Keys.output)
    }
    self.output = Path(output)
  }

  static func parseCommandOutput(yaml: Any) throws -> [Config.Entry.Output] {
    if let entry = yaml as? [String: Any] {
      return [try Config.Entry.Output(yaml: entry)]
    } else if let entry = yaml as? [[String: Any]] {
      return try entry.map({ try Config.Entry.Output(yaml: $0) })
    } else {
      throw Config.Error.wrongType(key: nil, expected: "Dictionary or Array", got: type(of: yaml))
    }
  }
}

/// Convert to CommandLine-equivalent string (for verbose mode, printing linting info, …)
///
extension Config.Entry.Output {
  func commandLineFlags() -> (templateFlag: String, outputFlag: String) {
    let tplFlag: String = {
      switch self.template {
      case .name(let name): return "-t \(name)"
      case .path(let path): return "-p \(path.string)"
      }
    }()

    return (templateFlag: tplFlag, outputFlag: "-o \(self.output)")
  }
}

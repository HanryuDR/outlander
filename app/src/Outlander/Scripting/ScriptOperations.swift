//
//  ScriptOperations.swift
//  Outlander
//
//  Created by Joe McBride on 2/26/21.
//  Copyright © 2021 Joe McBride. All rights reserved.
//

import Foundation

enum CheckStreamResult {
    case match(String)
    case none
}

class MoveOp: IWantStreamInfo {
    var id = ""
    let target: String

    init(_ target: String) {
        id = UUID().uuidString
        self.target = target
    }

    func stream(_ text: String, _ tokens: [StreamCommand], _: ScriptContext) -> CheckStreamResult {
        return .none
    }

    func execute(_ script: Script, _: ScriptContext) {
        script.next()
    }
}

class WaitforOp: IWantStreamInfo {
    var id = ""
    let target: String

    init(_ target: String) {
        id = UUID().uuidString
        self.target = target
    }

    func stream(_ text: String, _ tokens: [StreamCommand], _: ScriptContext) -> CheckStreamResult {
        // TODO: resolve target before comparision, it could contain a variable
        text.range(of: target) != nil
            ? .match(text)
            : .none
    }

    func execute(_ script: Script, _: ScriptContext) {
        script.next()
    }
}

class WaitforReOp: IWantStreamInfo {
    public var id = ""
    var pattern: String
    var groups: [String]

    init(_ pattern: String) {
        id = UUID().uuidString
        self.pattern = pattern
        groups = []
    }

    func stream(_ text: String, _ tokens: [StreamCommand], _: ScriptContext) -> CheckStreamResult {
        // TODO: resolve pattern before comparision, it could contain a variable
        var txt = text

        let regex = RegexFactory.get(pattern)
        guard let match = regex?.firstMatch(&txt) else {
            return .none
        }
        groups = match.values()
        return groups.count > 0 ? .match(txt) : .none
    }

    func execute(_ script: Script, _: ScriptContext) {
//        context.setRegexVars(self.groups)
        script.next()
    }
}

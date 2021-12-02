//
//  Regex.swift
//  Outlander
//
//  Created by Joseph McBride on 7/19/19.
//  Copyright © 2019 Joe McBride. All rights reserved.
//

import Foundation

extension Regex: Hashable {
    static func == (lhs: Regex, rhs: Regex) -> Bool {
        lhs.pattern == rhs.pattern
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pattern)
    }
}

enum RegexError: Error {
    case empty
}

class Regex {
    let log = LogManager.getLog(String(describing: Regex.self))

    var pattern: String
    var expression: NSRegularExpression

    init(_ pattern: String, options: NSRegularExpression.Options = []) throws {
        do {
            if pattern.isEmpty {
                throw RegexError.empty
            }

            self.pattern = pattern

            expression = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            log.error("Error building regex: \(error)")
            throw error
        }
    }

    public func replace(_ input: String, with template: String) -> String {
        let range = NSRange(input.startIndex..., in: input)
        return expression.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: template)
    }

    public func matches(_ input: String) -> [Range<String.Index>] {
        let range = NSRange(input.startIndex..., in: input)
        guard let result = expression.firstMatch(in: input, range: range) else {
            return []
        }

        var ranges: [Range<String.Index>] = []

        for i in 0 ..< result.numberOfRanges {
            let range = result.range(at: i)
            if let rng = Range(range, in: input) {
                ranges.append(rng)
            }
        }

        return ranges
    }

    public func hasMatches(_ input: String) -> Bool {
        var input2 = input
        return firstMatch(&input2) != nil
    }

    public func firstMatch(_ input: inout String) -> MatchResult? {
        let range = NSRange(input.startIndex..., in: input)
        guard let result = expression.firstMatch(in: input, range: range) else {
            return nil
        }

        return MatchResult(&input, result: result)
    }

    public func allMatches(_ input: inout String) -> [MatchResult] {
        let range = NSRange(input.startIndex..., in: input)
        let results = expression.matches(in: input, range: range)
        return results.map { res in
            MatchResult(&input, result: res)
        }
    }
}

class MatchResult {
    private let input: String
    private let result: NSTextCheckingResult

    init(_ input: inout String, result: NSTextCheckingResult) {
        self.input = input
        self.result = result
    }

    var count: Int {
        result.numberOfRanges
    }

    func rangeOfNS(index: Int) -> NSRange? {
        guard index < result.numberOfRanges else {
            return nil
        }

        return result.range(at: index)
    }

    func rangeOf(index: Int) -> Range<String.Index>? {
        guard index < result.numberOfRanges else {
            return nil
        }

        let nsRange = result.range(at: index)
        return Range(nsRange, in: input)
    }

    func valueAt(index: Int) -> String? {
        guard index < result.numberOfRanges else {
            return nil
        }

        let rangeIndex = result.range(at: index)
        if let range = Range(rangeIndex, in: input) {
            return String(input[range])
        }

        return nil
    }

    func values() -> [String] {
        (0 ... result.numberOfRanges).compactMap { valueAt(index: $0) }
    }

    func replace(target: String, prefix: String = "$") -> String {
        var result = target
        for (index, value) in values().enumerated() {
            result = result.replacingOccurrences(of: "\(prefix)\(index)", with: value)
        }
        return result
    }
}

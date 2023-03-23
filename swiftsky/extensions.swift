//
//  extensions.swift
//  swiftsky
//

import Foundation
import NaturalLanguage
import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}
extension RelativeDateTimeFormatter {
    convenience init(_ dateTimeStyle: DateTimeStyle) {
        self.init()
        self.dateTimeStyle = dateTimeStyle
    }
}
extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
    static let iso8601withTimeZone = ISO8601DateFormatter([.withInternetDateTime, .withTimeZone])
    static let relativeDateNamed = RelativeDateTimeFormatter(.named)
}
extension Date {
    var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
}
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension Locale {
    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages.compactMap({Locale(identifier: $0).language.languageCode?.identifier})
    }
}
extension String {
    var languageCode: String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return "en" }
        return languageCode
    }
}
class NSAction<T>: NSObject {
    let action: (T) -> Void

    init(_ action: @escaping (T)->()) {
        self.action = action
    }

    @objc func invoke(sender: AnyObject) {
        action(sender as! T)
    }
}

extension NSButton {
    func setAction(_ closure: @escaping(NSButton)->()) {
        let action = NSAction<NSButton>(closure)
        self.target = action
        self.action = #selector(NSAction<NSButton>.invoke)
        objc_setAssociatedObject(self, "\(self.hashValue)", action, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
extension NSMenuItem {
    func setAction(_ closure: @escaping(NSMenuItem)->()) {
        let action = NSAction<NSMenuItem>(closure)
        self.target = action
        self.action = #selector(NSAction<NSMenuItem>.invoke)
        objc_setAssociatedObject(self, "\(self.hashValue)", action, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
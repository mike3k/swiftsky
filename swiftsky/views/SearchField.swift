//
//  SearchField.swift
//  swiftsky
//

import SwiftUI

#if os(macOS)
struct SearchField: NSViewRepresentable {
  var textChanged: (String) async -> ()
  init(_ textChanged: @escaping (String) async -> ()) {
    self.textChanged = textChanged
  }
  class Coordinator: NSObject, NSSearchFieldDelegate {
    var parent: SearchField
    var task: Task<Void, Never>? = nil
    init(_ parent: SearchField) {
      self.parent = parent
    }
    func controlTextDidChange(_ notification: Notification) {
      guard let searchField = notification.object as? NSSearchField else {
        return
      }
      self.task?.cancel()
      self.task = Task {
        await self.parent.textChanged(searchField.stringValue)
      }
    }
  }
  func makeNSView(context: Context) -> NSSearchField {
    let searchfield = NSSearchField(frame: .zero)
    searchfield.delegate = context.coordinator
    return searchfield
  }
  func updateNSView(_ searchField: NSSearchField, context: Context) {
    
  }
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
}
#else
struct SearchField: UIViewRepresentable {
    func makeUIView(context: Context) -> UITextField {
        UITextField(frame: .zero)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {

    }

    typealias UIViewType = UITextField

  var textChanged: (String) async -> ()
  init(_ textChanged: @escaping (String) async -> ()) {
    self.textChanged = textChanged
  }
  class Coordinator: NSObject, UISearchTextFieldDelegate {
    var parent: SearchField
    var task: Task<Void, Never>? = nil
    init(_ parent: SearchField) {
      self.parent = parent
    }
    func controlTextDidChange(_ notification: Notification) {
      guard let searchField = notification.object as? UISearchTextField else {
        return
      }
      self.task?.cancel()
      self.task = Task {
          await self.parent.textChanged(searchField.text ?? "")
      }
    }
  }
  func makeNSView(context: Context) -> UISearchTextField {
    let searchfield = UISearchTextField(frame: .zero)
    searchfield.delegate = context.coordinator
    return searchfield
  }
  func updateNSView(_ searchField: UISearchTextField, context: Context) {

  }
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
}
#endif

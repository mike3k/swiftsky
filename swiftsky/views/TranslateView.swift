//
//  TranslateView.swift
//  swiftsky
//

import SwiftUI

struct TranslateView: View {
  @StateObject var viewmodel: TranslateViewModel
  @State var underline = false
  var body: some View {
    if viewmodel.error.isEmpty {
      if viewmodel.translatestatus == 1 {
        ProgressView().frame(maxWidth: .infinity, alignment: .center)
      }
      else {
        Button {
          viewmodel.translatetext()
        } label : {
          Text(viewmodel.showtranslated ? "Translated to \(GlobalViewModel.shared.systemLanguage) by Google Translate" : "Translate to \(GlobalViewModel.shared.systemLanguage)")
            .underline(underline)
            #if os(macOS)
            .foregroundColor(Color(NSColor.linkColor))
            .hoverHand {
              underline = $0
            }
            #else
            .foregroundColor(Color(UIColor.link))
            #endif
        }
        .disabled(viewmodel.translatestatus == 1)
        .buttonStyle(.plain)
        if viewmodel.showtranslated && !viewmodel.translatedtext.isEmpty  {
          Text(.init(viewmodel.translatedtext))
            .padding(.bottom, 3)
        }
      }
    }
    else {
      Group {
        Text("Error: \(viewmodel.error)")
        Button("\(Image(systemName: "arrow.clockwise")) Retry") {
          viewmodel.error = ""
          viewmodel.translatetext()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .frame(maxWidth: .infinity, alignment: .center)
    }
  }
}

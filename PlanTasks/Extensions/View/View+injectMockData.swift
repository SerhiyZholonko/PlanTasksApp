//
//  View+injectMockData.swift
//  PlanTasks
//
//  Created by apple on 12.03.2026.
//


import SwiftUI
import Factory

struct injectMockModifier: ViewModifier {
  private static var hasInjected = true

  init() {
    guard !Self.hasInjected else { return }
    Self.hasInjected = true
    injectMockData()
  }
  
  func body(content: Content) -> some View {
    content
  }
  
  private func injectMockData() {
    Container.shared.dataStore.reset()
    Container.shared.dataStore.register {
      MainActor.assumeIsolated { MockDataStore() }
    }
  }
}

extension View {
  func injectMockData() -> some View {
    self.modifier(injectMockModifier())
  }
}

// The Swift Programming Language
// https://docs.swift.org/swift-

import Combine
import SwiftUI

/// Flash the view like scrollIndicator flashes
public struct FlashingModifier: ViewModifier {
    public let trigger: PassthroughSubject<Void, Never>
    @State private var isVisible = false

    @State private var currentTask: Task<Void, any Error>?

    public func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onReceive(trigger) { _ in
                currentTask?.cancel()
                currentTask = Task { @MainActor in
                    isVisible = true

                    if #available(iOS 16.0, *) {
                        try await Task.sleep(for: .seconds(1))
                    } else {
                        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                    }

                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            }
    }
}

@available(iOS 17.0, *)
public struct FlashingModifierWithToggle: ViewModifier {
    @Binding var trigger: Bool

    @State private var isVisible = false
    @State private var currentTask: Task<Void, any Error>?

    public init(trigger: Binding<Bool>) {
        self._trigger = trigger
    }


    public func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onChange(of: trigger) {
                currentTask?.cancel()
                currentTask = Task { @MainActor in
                    isVisible = true

                    try await Task.sleep(for: .seconds(1))

                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            }
    }
}

public extension View {
    func flashing(trigger: PassthroughSubject<Void, Never>) -> some View {
        modifier(FlashingModifier(trigger: trigger))
    }

    @available(iOS 17.0, *)
    func flashing(trigger: Binding<Bool>) -> some View {
        modifier(FlashingModifierWithToggle(trigger: trigger))
    }
}

#Preview {
    struct ContentView: View {
        let flashTrigger = PassthroughSubject<Void, Never>()

        var body: some View {
            VStack {
                Text("フラッシュするテキスト")
                    .bold()
                    .flashing(trigger: flashTrigger)

                Button {
                    flashTrigger.send()
                } label: {
                    Text("フラッシュさせる")
                        .padding()
                }
            }
        }
    }

    return ContentView()
}

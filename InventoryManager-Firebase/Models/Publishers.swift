//
//  Publishers.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/9/24.
//

import SwiftUI
import Combine

struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                self.cancellable = Publishers.keyboardHeight
                    .sink { height in
                        withAnimation {
                            self.keyboardHeight = height
                        }
                    }
            }
            .onDisappear {
                self.cancellable?.cancel()
            }
    }
}

// Publisher to detect keyboard height
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map { (notification) -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }

        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in 0 }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

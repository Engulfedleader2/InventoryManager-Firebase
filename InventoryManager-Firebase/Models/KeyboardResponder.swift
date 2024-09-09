//
//  KeyboardResponder.swift
//  InventoryManager-Firebase
//
//  Created by Israel on 9/9/24.
//

import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap { notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            }
            .map { rect in
                rect.height
            }
            .sink { [weak self] height in
                self?.currentHeight = height
            }
    }
}

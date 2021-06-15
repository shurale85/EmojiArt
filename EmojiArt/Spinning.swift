//
//  Spinning.swift
//  EmojiArt
//
//  Created by NewUSER on 13.03.2021.
//

import SwiftUI

struct Spinning: ViewModifier {
    
    
    //vr of view tha is kept in heap
    @State var isVisible = false
    func body(content: Content) -> some View {
        content.rotationEffect(Angle(degrees: isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear{ isVisible = true}
    }
}

extension View {
    func spinning() -> some View {
        self.modifier(Spinning())
    }
}

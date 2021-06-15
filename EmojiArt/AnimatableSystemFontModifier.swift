//
//  AnimatableSystemFontModifier.swift
//  EmojiArt
//
//  Created by NewUSER on 06.03.2021.
//

import SwiftUI
//for coorectly scale emojis
struct AnimatableSystemFonrModifier: AnimatableModifier {
    var size: CGFloat
    var weigth: Font.Weight = .regular
    var design: Font.Design = .default

    func body(content: Content) -> some View {
        content.font(Font.system(size: size, weight: weigth, design: design))
    }
    
    var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }
}

extension View {
    func font(animatableWithSize size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.modifier(AnimatableSystemFonrModifier(size: size, weigth: weight, design: design))
    }
}

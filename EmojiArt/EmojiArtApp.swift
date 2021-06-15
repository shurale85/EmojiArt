//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by NewUSER on 28.02.2021.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    
    let store = EmojiArtDocumentStore(named: "Emoji Art")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentChooser().environmentObject(store)
            //EmojiArtDocumentView(document: EmojiArtDocument())
        }
    }
    
    init(){
      //  store.addDocument()
        //store.addDocument(named: "Hello world")
    }
}

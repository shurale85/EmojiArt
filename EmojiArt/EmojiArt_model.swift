//
//  EmojiArt_model.swift
//  EmojiArt
//
//  Created by NewUSER on 28.02.2021.
//

import Foundation

struct EmojiArt: Codable { //
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Codable, Hashable {
        let text: String
        var x: Int //offset from center
        var y: Int //offset from center
        var size: Int
        let id: Int
        
        init(text: String, x: Int, y: Int, size: Int, id: Int) { //fileprivate makes init availble within this file only
            self.text = text
            self.x = x
            self.y = y
            self.id = id
            self.size = size
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self) // Requires self and its property to confirm Encodable or Encodable
    }
    
    // 8/36:05 init? failable initializer can return nil.
    // due this init? free initializer is lost so we have to specify explicitly
    init? (json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt
        } else {
            return nil
        }
    }
    
    //defining defalut init since init? closes this default init
    init(){}
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y:Int, size: Int){
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: x, size: size, id: uniqueEmojiId))
    }
}

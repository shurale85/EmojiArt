//
//  EmojiArtDocument(view_model).swift
//  EmojiArt
//
//  Created by NewUSER on 28.02.2021.
//

import SwiftUI
import Combine // publisghing staff

class EmojiArtDocument: ObservableObject, Hashable, Identifiable {
    
    let id: UUID
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    
    //this function is required by HAshable
    func hash(into hasher: inout Hasher) {
        //takes hashable object
        hasher.combine(id)
    }
    
    static let palette: String = "🌩🌈☀️🛸🚁🥅"

    private static let untitled = "EmojiArtDocument.Untitled"
/* one way
    @Published
    private var emojiArt: EmojiArt {
        //this was a workaround when swift had problems using @Published with didSet
        /*willSet {
            objectWillChange.send()
        }*/
        didSet {
            UserDefaults.standard.setValue(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
    } //model
 */
    //another way by using projected value $emojiArt that is publisher
    //  9/ 37:40
    @Published private var emojiArt: EmojiArt
    
    
    // 9/ 39:00
    private var autosaveCancellable: AnyCancellable?
    
    //with default UUISD so thete is no need to pass
    init(id: UUID? = nil)
    {
        self.id = id ?? UUID() //this way internal implementation of id is hiiden from the world
        let defaultKey = "EmojiArtDocument.\(self.id.uuidString  )"
        emojiArt = EmojiArt(json:UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink { emojiArt in
            print("\(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.setValue(emojiArt.json, forKey: defaultKey)
        }
        fetchBackgroundImageDataByUrlSession() //UserDefault does not save image, just url
    }
    
    
    //publishing this will cause View to redraw whenever it is changed
    @Published private(set) var backgroundImage: UIImage? //not image 7/01:04:10
    
    var emojis: [EmojiArt.Emoji] {emojiArt.emojis}
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat){
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize){
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat){
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundURL: URL? {
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            //fetchBackgroundImageData()
            //backgroundImage = nil
            fetchBackgroundImageDataByUrlSession()
        }
        get {
            emojiArt.backgroundURL
        }
        
    }
    
    //nw_protocol_get_quic_image_block_invoke dlopen libquic failed
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        //more sofisticated why is to use URLSession 7/01:10:25
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async{
                if let imageData = try? Data(contentsOf: url) { // ? means try and if error return nil
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL { //tp prevent the case when first image is loaded long, user pick up another image and trying to set it. Then first image will
                            // be set and then a second image will be set
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    
    private func fetchBackgroundImageDataByUrlSession_old() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            let task = URLSession.shared.dataTask(with: url){ data, response, error in
                guard let data = data else {
                    return
                }
                
                DispatchQueue.main.async {
                    if url == self.emojiArt.backgroundURL {
                        self.backgroundImage = UIImage(data: data)
                    }
                }
            }
            
            task.resume();
        }
    }
    
    private var fetchImageCancellable: AnyCancellable?
    //using publisher
    private func fetchBackgroundImageDataByUrlSession() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel() //cancel previous loading if user choosed another one
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, irlResponse  in UIImage(data: data)}
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
            
        }
    }
    
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y))}
}

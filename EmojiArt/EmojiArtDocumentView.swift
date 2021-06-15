//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by NewUSER on 28.02.2021.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @ObservedObject var document:EmojiArtDocument
    
    
    //it is not usail way to do? but it demonstrates State mechanizm 10/3:50
    @State var chosenPalette: String = ""
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PalleteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                     HStack {
                         ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in // \.self is key path 7/33:20 it is var on another object; may looks like \.foo.bar
                             Text(emoji)
                                 .font(Font.system(size: defaultEmojiSize))
                                 .onDrag { NSItemProvider(object: emoji as NSString)}
                         }
                     }
                 }
                .onAppear{chosenPalette = document.defaultPalette}
            }
                GeometryReader { geometry in
                    ZStack {
                        //why not zstack 7/01:02:20 - to take all space
                        Color.white.overlay(
                            //overlay takes view but if is not view that's why wrapping with viewbuilder
                            // Group does not modify view so it is sutable in this case
                           /*
                            Group {
                                if self.document.backgroundImage != nil {
                                        Image(uiImage: self.document.backgroundImage!)
                                    }
                                }
                            */
                            //this is bacjground
                            OptionalImage(uiImage:document.backgroundImage)
                                .scaleEffect(zoomScale)
                                .offset(gesturePanOffset)
                        )
                        .gesture(doubleTapZoom(in: geometry.size))
                            if isLoading {
                                Image(systemName: "hourglass").imageScale(.large).spinning()
                                
                            } else
                            {
                                //emojis go here
                                    ForEach(document.emojis) {emoji in
                                    Text(emoji.text)
                                       // .font(self.font(for: emoji)) emojis scale wrong
                                        .font(animatableWithSize: emoji.fontSize * zoomScale)
                                        .position(self.position(for: emoji, in: geometry.size))
                            }
                        }
                    }
                    .clipped() // to prevent backgraound image overlaying
                    .gesture(panGesture())
                    .gesture(zoomGesture())
                    .edgesIgnoringSafeArea([.horizontal, .bottom])
                    //fitting image to backgroubd size once it is donwloaded
                    .onReceive(document.$backgroundImage){ image in
                        zoomToFit(image, in: geometry.size)
                        
                    }
                    .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                        //about coordinate cenvertion 7/1:20:38 converting from ios Coor System (0,0 is upper left) to image CS (0,0 is image center)
                        var location = geometry.convert(location, from: .global)
                        location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                        location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                        location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                        return self.drop(providers: providers, at: location)
                    }
                    .navigationBarItems(trailing: Button(action: {
                        if let url = UIPasteboard.general.url, url != document.backgroundURL {
                            confirmBackgroundPAste = true
                        } else {
                            self.explainBackgroundPaste = true
                        }
                    }, label: {
                        Image(systemName: "doc.on.clipboard").imageScale(.large)
                            .alert(isPresented: $explainBackgroundPaste){
                                return Alert(
                                    title: Text("Paste Backgound"),
                                    message: Text("Copy the URL of an image to the clipboard and touch this button"),
                                    dismissButton: .default(Text("Ok"))
                            )
                    }
                }))
            }
                //keybord button becomes unavailable since view is zoomed although it stays visible. 10 1:41
                .zIndex(-11)
        
        }
        .alert(isPresented: $confirmBackgroundPAste){
            Alert(
                title:Text("Paste Background"),
                message: Text("Replace your backgound with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                primaryButton: .default(Text("OK")) {
                    document.backgroundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }

@State private var explainBackgroundPaste = false;
    @State private var confirmBackgroundPAste = false;
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    // zooming by douple tap/click
    private func doubleTapZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.linear(duration:4)) {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    //two pieces of state
    //this one is for steady steady state, not when gester is going on
    //As mutable View property it is marked as @State
    @State private var steadyStateZoomScale: CGFloat = 1.0 // 8/58:40
    //it can be any type, it's for keep tracking
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    // zooming by two fingers /alt+right button
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            // $ is binding
            // 8/1:04:25 about 2nd param. Only Magninfication can change  @GesterState gestureZoomScale by passing it and then getting it back modified (inOut param)
            //once gester is done @GesterState gestureZoomScale it will set to initial value
            .updating($gestureZoomScale) { latestGesterScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGesterScale
                                
            }
            .onEnded { finalGesterScale in
                steadyStateZoomScale *= finalGesterScale
            }
    }
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image,  image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = CGSize.zero //reset to center
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transition in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded{ finalGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalGestureValue.translation / zoomScale)
            }
    }
    
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize * zoomScale)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint{
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
        return location
        
        
    }
    private func drop(providers:[NSItemProvider], at location:CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
                
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40;
}

// this solution works in this case but is wrong in common. Don't use it
// provide id that is required by foreach
/*
 extension String: Identifiable {
    public var id: String {return self}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}*/

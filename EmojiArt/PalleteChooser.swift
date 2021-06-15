//
//  PalleteChooser.swift
//  EmojiArt
//
//  Created by NewUSER on 13.03.2021.
//

import SwiftUI

struct PalleteChooser: View {
    
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(onIncrement:
                        {
                            chosenPalette = document.palette(after: chosenPalette)
                        },
                    onDecrement: {
                        chosenPalette = document.palette(before: chosenPalette)
                    },
                    label: {EmptyView()})
            Text(document.paletteNames[chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    showPaletteEditor = true
                }
                //another way is sheet
                .popover(isPresented: $showPaletteEditor ) {
                    PaletteEditor(chosenPalette: $chosenPalette, isShowing: $showPaletteEditor)
                        //PaletteEditor is seperate view that's why we need to pass VM via envObj
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        //it takes size it fits and not take extra space offered
        .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
    }
}

struct PaletteEditor: View {
    
    //this is how VM is shared (because this view is represented as seperate view)
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0){
            ZStack{
                Text("Palette Editor").font(.headline).padding()
                HStack{
                    Spacer()
                    Button(action: {
                        isShowing = false
                    }, label: { Text("Done") }).padding()
                }
            }
            Divider()
            //Form makes used space more occurate and add more functionality
            Form {
                Section(header: Text("Palette Name")) {
                    TextField("Palette Name", text: $paletteName,
                              //saving the changes from edit field
                              onEditingChanged: { began in
                                if !began {
                                    document.renamePalette(chosenPalette, to: paletteName)
                                }
                              })
                    TextField("Add Emoji", text: $emojisToAdd,
                              onEditingChanged: { began in
                                if !began {
                                    chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                                    emojisToAdd = ""
                                }
                              })
                }
                Section(header: Text("Remove Emoji")) {
                    VStack{
                       // instead of ForEach
                       Grid(chosenPalette.map {String($0)}, id:\.self){ emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                                .onTapGesture {
                                    chosenPalette = document.removeEmoji(emoji, fromPalette: chosenPalette)
                                }
                        }
                       .frame(height: self.height)
                    }
                    
                }
            }
            .onAppear{ paletteName = document.paletteNames[chosenPalette] ?? ""}
        }
        
    }
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
    
    var fontSize: CGFloat = 40
}

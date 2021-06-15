//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by NewUSER on 21.03.2021.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    
    //it is common to use EO in tol level view
    @EnvironmentObject var store: EmojiArtDocumentStore
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView{
            //ForEach does not create layout we use List
            List {
                ForEach(store.documents) { document in
                    NavigationLink(
                        destination: EmojiArtDocumentView(document: document).navigationTitle(store.name(for: document)))
                        {
                        EditableText(store.name(for: document), isEditing: editMode.isEditing) {name in
                            store.setName(name, for:document)
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    indexSet.map {store.documents[$0]} .forEach{ document in
                        store.removeDocument(document)
                    }
                })
            }
            .navigationTitle(store.name)
            .navigationBarItems(leading: Button( action: {
                store.addDocument()
                
                },
                label: { Image(systemName: "plus").imageScale(.large)
                }),
                trailing: EditButton()
            )
            //10 1:34:00
            .environment(\.editMode, $editMode)
            
        }
     }
    
    init()
    {
       //  print(store)
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}

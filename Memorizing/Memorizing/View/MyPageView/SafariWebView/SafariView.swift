//
//  SafariView.swift
//  Memorizing
//
//  Created by 염성필 on 2023/02/01.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
   
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
       
        return SFSafariViewController(url: URL(string: "https://crystalline-honey-179.notion.site/7186dcfc77794dd593dc292be31df131")!)
     
    }
    
    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) {
        // ...
    }
}

struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
        SafariView()
    }
}

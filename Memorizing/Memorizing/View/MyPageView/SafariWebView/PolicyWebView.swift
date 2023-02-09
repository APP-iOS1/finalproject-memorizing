//
//  PolicyWebView.swift
//  Memorizing
//
//  Created by Jae hyuk Yim on 2023/02/09.
//

import SwiftUI

import SwiftUI
import SafariServices

struct PolicyWebView: UIViewControllerRepresentable {
   
    func makeUIViewController(context: UIViewControllerRepresentableContext<PolicyWebView>) -> SFSafariViewController {
       
        return SFSafariViewController(url: URL(string: "https://crystalline-honey-179.notion.site/4b2f1810b30e42ba84cd5706622db5cf")!)
     
    }
    
    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<PolicyWebView>
    ) {
        // ...
    }
}

struct PolicyWebView_Previews: PreviewProvider {
    static var previews: some View {
        PolicyWebView()
    }
}

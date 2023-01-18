//
//  hideKeyboradExtension.swift
//  Ditor_personal project
//
//  Created by Jae hyuk Yim on 2023/01/11.
//

import Foundation
import UIKit
import SwiftUI


// MARK: - 빈 공간을 눌렀을 때, 키보드가 자동으로 내려감
extension UIApplication {
    func hideKeyboard() {
        guard let window = windows.first else { return }
        let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        window.addGestureRecognizer(tapRecognizer)
    }
 }
 
extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

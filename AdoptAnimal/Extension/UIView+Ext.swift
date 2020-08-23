//
//  SpinnerViewController.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/21.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

extension UIView {
    static let loadingViewTag = 101
    func showLoading(style: UIActivityIndicatorView.Style = .medium, color: UIColor? = nil, constant: CGFloat? = nil) {
        var loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
        if loading == nil {
            loading = UIActivityIndicatorView(style: style)
        }
        if let color = color {
            loading?.color = color
        }
    
        loading?.translatesAutoresizingMaskIntoConstraints = false
        loading!.startAnimating()
        loading!.hidesWhenStopped = true
        loading?.tag = UIView.loadingViewTag
        addSubview(loading!)
        if let constant = constant {
            loading?.centerYAnchor.constraint(equalTo: centerYAnchor, constant: constant).isActive = true
        }
    
        loading?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func stopLoading() {
        let loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
        loading?.stopAnimating()
        loading?.removeFromSuperview()
    }
}


//
//  SearchFooter.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/9.
//  Copyright © 2020 Bozin. All rights reserved.
//

import UIKit

class SearchFooter: UIView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureView()
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = bounds
    }
    
    func setNotFiltering() {
        label.text = ""
        hideFooter()
    }
    
    func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        if filteredItemCount == totalItemCount {
            setNotFiltering()
        } else if filteredItemCount == 0 {
            label.text = "沒有符合您查詢的項目"
            showFooter()
        } else {
            label.text = "浪浪數量：\(filteredItemCount)"
            showFooter()
        }
    }
    
    func hideFooter() {
        UIView.animate(withDuration: 0.7) {
            self.alpha = 0.0
        }
    }
    
    func showFooter() {
        UIView.animate(withDuration: 0.7) {
            self.alpha = 1.0
        }
    }
    
    func configureView() {
        backgroundColor = UIColor(red: 30, green: 136, blue: 229)
        alpha = 0.0
        
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont(name: "Rubik", size: 20)
        addSubview(label)
    }
}

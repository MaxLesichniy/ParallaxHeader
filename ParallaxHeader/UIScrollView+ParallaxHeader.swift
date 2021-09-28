//
//  UIScrollView+ParallaxHeader.swift
//  ParallaxHeader
//
//  Created by Roman Sorochak on 6/23/17.
//  Copyright © 2017 MagicLab. All rights reserved.
//

import UIKit
import ObjectiveC.runtime


/**
 A UIScrollView extension with a ParallaxHeader.
 */
extension UIScrollView {
    
    private struct AssociatedKeys {
        static var parallaxHeader = "AssociatedKeys.parallaxHeader"
    }
    
    /**
     The parallax header.
     */
    public var parallaxHeader: ParallaxHeader {
        get {
            if let header = objc_getAssociatedObject(self, &AssociatedKeys.parallaxHeader) as? ParallaxHeader {
                return header
            }
            let header = ParallaxHeader()
            self.parallaxHeader = header
            return header
        }
        set {
            newValue.scrollView = self
            objc_setAssociatedObject(self, &AssociatedKeys.parallaxHeader, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


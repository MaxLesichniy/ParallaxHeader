//
//  ParallaxHeader.swift
//  ParallaxHeader
//
//  Created by Roman Sorochak on 6/22/17.
//  Copyright © 2017 MagicLab. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

public typealias ParallaxHeaderHandlerBlock = (_ parallaxHeader: ParallaxHeader) -> Void

private let parallaxHeaderKVOContext = UnsafeMutableRawPointer.allocate(
    byteCount: 4,
    alignment: 1
)

public class ParallaxView: UIView {
    
    fileprivate weak var parent: ParallaxHeader!
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        guard let scrollView = self.superview as? UIScrollView else { return }
        scrollView.removeObserver(
            self.parent,
            forKeyPath: NSStringFromSelector(#selector(getter: scrollView.contentOffset)),
            context: parallaxHeaderKVOContext
        )
//        scrollView.removeObserver(
//            self.parent,
//            forKeyPath: NSStringFromSelector(#selector(getter: scrollView.contentInset)),
//            context: parallaxHeaderKVOContext
//        )
    }
    
    public override func didMoveToSuperview() {
        guard let scrollView = self.superview as? UIScrollView else { return }
        scrollView.addObserver(
            self.parent,
            forKeyPath: NSStringFromSelector(#selector(getter: scrollView.contentOffset)),
            options: .new,
            context: parallaxHeaderKVOContext
        )
//        scrollView.addObserver(
//            self.parent,
//            forKeyPath: NSStringFromSelector(#selector(getter: scrollView.contentInset)),
//            options: [.new, .old],
//            context: parallaxHeaderKVOContext
//        )
    }
}


/**
 The ParallaxHeader class represents a parallax header for UIScrollView.
 */
public class ParallaxHeader: NSObject {
        
    /**
     Block to handle parallax header scrolling.
     */
    public var parallaxHeaderDidScrollHandler: ParallaxHeaderHandlerBlock?
    
    public internal(set) weak var scrollView: UIScrollView? {
        didSet {
            guard scrollView != oldValue,
                  let scrollView = scrollView else {
                return
            }
            
            adjustScrollViewTopInset(top: scrollView.contentInset.top + height)
            scrollView.addSubview(contentView)
            layoutContentView()
        }
    }
    
    /**
     The content view on top of the UIScrollView's content.
     */
    public internal(set) lazy var contentView: ParallaxView = { [unowned self] in
        let contentView = ParallaxView()
        contentView.parent = self
        contentView.clipsToBounds = true
        return contentView
    }()
    
    /**
     The header's view.
     */
    public weak var view: UIView? {
        didSet {
            guard oldValue != view else { return }
            oldValue?.removeFromSuperview()
            
            if let view = view {
                view.translatesAutoresizingMaskIntoConstraints = false
                contentView.insertSubview(view, at: 0)
                updateConstraints()
            }
        }
    }
    
    /**
     The parallax header behavior mode. By default is fill mode.
     */
    public var mode: ParallaxHeaderMode = .fill {
        didSet {
            guard mode != oldValue else { return }
            updateConstraints()
        }
    }
    
    /**
     The header's default height. 0 0 by default.
     */
    public var height: CGFloat = 0 {
        didSet {
            guard height != oldValue,
                  let scrollView = scrollView else { return }

//            viewHeightConstraint?.constant = height
            adjustScrollViewTopInset(top: scrollView.contentInset.top - oldValue + height)
            layoutContentView()
        }

    }
    
    /**
     The header's minimum height while scrolling up. 0 by default.
     */
    public var minimumHeight: CGFloat = 0 {
        didSet {
            guard minimumHeight != oldValue else { return }
            layoutContentView()
        }
    }
    
    public var adjustScrollViewContentInsets: Bool = true {
        didSet {
            guard adjustScrollViewContentInsets != oldValue else { return }
            layoutContentView()
        }
    }
    
    public var adjustSafeAreaInsets: Bool = true {
        didSet {
            guard adjustSafeAreaInsets != oldValue else { return }
            layoutContentView()
        }
    }
    
    /**
     The parallax header progress value.
     */
    public internal(set) var progress: CGFloat = 0 {
        didSet {
            guard progress != oldValue else { return }
            parallaxHeaderDidScrollHandler?(self)
        }
    }
    
//    fileprivate weak var viewHeightConstraint: NSLayoutConstraint?
    fileprivate var contentViewConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Constraints
    
    private func updateConstraints() {
        contentViewConstraints.forEach {
            contentView.removeConstraint($0)
        }
        
        contentViewConstraints.removeAll()
        
        switch mode {
        case .fill:
            setFillModeConstraints()
        case .top:
            setTopModeConstraints()
        case .topFill:
            setTopFillModeConstraints()
        case .center:
            setCenterModeConstraints()
        case .centerFill:
            setCenterFillModeConstraints()
        case .bottom:
            setBottomModeConstraints()
        case .bottomFill:
            setBottomFillModeConstraints()
        }
        
        contentView.addConstraints(contentViewConstraints)
    }
    
    private func setFillModeConstraints() {
        guard let view = self.view else { return }
        
        let binding = [
            "v" : view
        ]
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|",
            options: [],
            metrics: nil,
            views: binding
        )
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[v]|",
            options: [],
            metrics: nil,
            views: binding
        )
    }
    
    private func setTopModeConstraints() {
        guard let view = self.view else { return }
        
        let binding = [
            "v" : view
        ]
        
        let metrics = [
            "height" : height
        ]
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: binding
        )
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[v(==height)]", options: [], metrics: metrics, views: binding
        )
    }
    
    private func setTopFillModeConstraints() {
        guard let view = self.view else { return }
        
        let binding = [
            "v" : view
        ]
        
        let metrics = [
            "highPriority" : UILayoutPriority.defaultHigh,
            "height" : height
        ] as [String : Any]
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: binding
        )
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[v(>=height)]-0.0@highPriority-|",
            options: [], metrics: metrics, views: binding
        )
    }
    
    private func setCenterModeConstraints() {
        guard let view = self.view else { return }
        
        let binding = [
            "v" : view
        ]
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: binding
        )
        
        contentViewConstraints += [
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal,
                               toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal,
                               toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        ]
    }
    
    private func setCenterFillModeConstraints() {
        guard let view = self.view else { return }
        
        let binding = [
            "v" : view
        ]
        
        let metrics = [
            "highPriority" : UILayoutPriority.defaultHigh,
            "height" : height
        ] as [String : Any]
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: binding
        )
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0@highPriority-[v(>=height)]-0@highPriority-|",
            options: [], metrics: metrics, views: binding
        )
        
        contentViewConstraints += [
            NSLayoutConstraint(
                item: view, attribute: .centerY, relatedBy: .equal,
                toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(
                item: view, attribute: .centerX, relatedBy: .equal,
                toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        ]
    }
    
    private func setBottomModeConstraints() {
        guard let view = self.view else { return }
        
        let binding = [
            "v" : view
        ]
        
        let metrics = [
            "height" : height
        ]
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: binding
        )
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:[v(==height)]|", options: [], metrics: metrics, views: binding
        )
    }
    
    private func setBottomFillModeConstraints() {
        guard let view = self.view else { return }
        
        let binding = [
            "v" : view
        ]
        
        let metrics = [
            "highPriority" : UILayoutPriority.defaultHigh,
            "height" : height
        ] as [String : Any]
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|",
            options: [], metrics: nil, views: binding
        )
        
        contentViewConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0.0@highPriority-[v(>=height)]|",
            options: [], metrics: metrics, views: binding
        )
    }
    
    
    // MARK: - Private
        
    private func layoutContentView() {
        guard let scrollView = scrollView else { return }
        
        let minimumHeight = min(self.minimumHeight, self.height)
        var relativePosition = scrollView.contentOffset.y + scrollView.contentInset.top - height
        if self.adjustSafeAreaInsets {
            relativePosition += scrollView.safeAreaInsets.top
        }
        var relativeHeight = -relativePosition
        if !self.adjustScrollViewContentInsets {
            let inset = scrollView.contentInset.top - height
            relativePosition -= inset
            relativeHeight -= inset
        }
        
        let frame = CGRect(
            x: 0,
            y: relativePosition,
            width: scrollView.frame.size.width,
            height: max(relativeHeight, minimumHeight)
        )
        contentView.frame = frame
        
        let div = self.height - self.minimumHeight
        progress = (self.contentView.frame.size.height - self.minimumHeight) / div
    }
    
    private var disableObserving: Bool = false
    
    private func adjustScrollViewTopInset(top: CGFloat) {
        guard let scrollView = scrollView else { return }
        
        disableObserving = true
        
        var inset = scrollView.contentInset
        
        // Adjust content offset
        var offset = scrollView.contentOffset
        offset.y += inset.top - top
        scrollView.contentOffset = offset
        
        // Adjust content inset
        inset.top = top
        scrollView.contentInset = inset
        
        disableObserving = false
    }
    
    
    //MARK: - KVO
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == parallaxHeaderKVOContext,
              let scrollView = scrollView else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
//        guard !disableObserving else { return }
        
        if keyPath == NSStringFromSelector(#selector(getter: scrollView.contentOffset)) {
            layoutContentView()
        }
//        if keyPath == NSStringFromSelector(#selector(getter: scrollView.adjustedContentInset)) {
//            layoutContentView()
//           let oldValue = change?[.oldKey] as? UIEdgeInsets {
//            adjustScrollViewTopInset(top: scrollView.contentInset.top - oldValue.top + height)
//        }
    }
}

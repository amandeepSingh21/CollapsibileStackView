//
//  CollapsibileStackViewItem.swift
//  CollapsibleStackView
//
//  Created by Amandeep on 16/11/20.
//  Copyright © 2020 Amandeep. All rights reserved.
//

import Foundation
import UIKit

protocol AnimationDelegate:class {
    func didFinishExpandAnimation()
    func didFinishCollapseAnimation()
}

public enum CollapsibleStackViewItemState {
    case collapsed
    case expanded
    case partialCollapsed
    case partialExpanded
    
    fileprivate var isZeroHeightConstraintActive: Bool {
        switch self {
        case .collapsed,.partialCollapsed:
            return true
        case .expanded,.partialExpanded:
            return false
        }
    }
}


public class CollapsibleStackViewItem: UIStackView {
    weak var delegate: AnimationDelegate?
    public var state: CollapsibleStackViewItemState = .collapsed {
        didSet {
            switch state {
            case .expanded:
                self.expand()
            case .partialCollapsed:
                self.partiallyCollapse()
            case .collapsed:
                self.collapse()
            case .partialExpanded:
                self.partiallyExpand()
            }
        }
    }
    
    private var zeroHeightConstraint: NSLayoutConstraint?
    private var bodyZeroHeightConstraint: NSLayoutConstraint?
    
    init(_ views: [UIView], makeHeightZero: Bool = true, delegate: AnimationDelegate?) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        self.axis = .vertical
        if makeHeightZero {
            self.addZeroHeightConstraint()
        }
        _ = views.map { addArrangedSubview($0) }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addZeroHeightConstraint() {
        zeroHeightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        zeroHeightConstraint?.isActive = true
        
    }
        
    private func expand() {
        self.superview?.superview?.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.zeroHeightConstraint?.isActive = self.state.isZeroHeightConstraintActive
            self.superview?.superview?.layoutIfNeeded()
        }) { (_) in
            self.delegate?.didFinishExpandAnimation()
        }
    }
    
    private func partiallyCollapse() {
        guard let body = self.arrangedSubviews.last else { return }
        self.bodyZeroHeightConstraint = body.heightAnchor.constraint(equalToConstant: 0)
    
        self.superview?.superview?.layoutIfNeeded()
        body.alpha = 1
        UIView.animate(withDuration: 0.4, animations: {
            body.alpha = 0
              self.bodyZeroHeightConstraint?.isActive = self.state.isZeroHeightConstraintActive
                      self.superview?.superview?.layoutIfNeeded()
        }) { (_) in
             
        }
    }
    
    private func collapse() {
        self.alpha = 1
        self.superview?.superview?.layoutIfNeeded()
        self.bodyZeroHeightConstraint?.isActive = !self.state.isZeroHeightConstraintActive
        UIView.animate(withDuration: 0.4, animations: {
             self.alpha = 0
            self.zeroHeightConstraint?.isActive = self.state.isZeroHeightConstraintActive
            self.superview?.superview?.layoutIfNeeded()
        }) { (completed) in
            self.removeFromSuperview()
            self.delegate?.didFinishCollapseAnimation()
        }
        
       
    }
    
    private func partiallyExpand() {
        guard let body = self.arrangedSubviews.last else { return }
        body.alpha = 0
        self.superview?.superview?.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            body.alpha = 1
            self.bodyZeroHeightConstraint?.isActive = false
            self.superview?.superview?.layoutIfNeeded()
        }
    }

}

//
//  CollapsibileStackView.swift
//  CollapsibleStackView
//
//  Created by Amandeep on 16/11/20.
//  Copyright © 2020 Amandeep. All rights reserved.
//

import Foundation
import UIKit

public protocol CollapsibleStackViewDatasource: class {
    func cardStack(_ collapsibleStackView: CollapsibleStackView, viewForIndex index: Int, state: CollapsibleStackViewItemState) -> UIView
    func cardStack(_ collapsibleStackView: CollapsibleStackView, headerForIndex index: Int, state: CollapsibleStackViewItemState) -> UIView
    func numberOfItems(in collapsibleStackView: CollapsibleStackView) -> Int
    func cardStack(_ collapsibleStackView: CollapsibleStackView, footerForIndex index: Int) -> UIView?
}

public protocol CollapsibleStackViewDelegate: class {
    func cardStack(_ collapsibleStackView: CollapsibleStackView, didSelectItemAt index: Int)
    func cardStack(_ collapsibleStackView: CollapsibleStackView, didSelectFooterAt index: Int)
}


public class CollapsibleStackView: UIStackView {
    //MARK:- Props
    private var index: Int = 0
    private var footer: UIView?
    private var numberOfItems = 0
    private let collapseAnimationSync = DispatchGroup()
    
    lazy private var bodyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    //MARK:- Delegates
    public weak var datasource: CollapsibleStackViewDatasource? {
        didSet {
            load()
        }
    }
    public weak var delegate: CollapsibleStackViewDelegate?
    
    //MARK:- Init
    public init() {
        super.init(frame: .zero)
        self.axis = .vertical
        self.addArrangedSubview(bodyStackView)
                
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func state(for index: Int) -> CollapsibleStackViewItemState {
        let item = self.bodyStackView.arrangedSubviews[index] as! CollapsibleStackViewItem
        return item.state
    }
    
    
}

//MARK:- Data loadeer
extension CollapsibleStackView {
    private func load() {
        index = 0
        guard let datasource = datasource else { return }
        numberOfItems = datasource.numberOfItems(in: self)
        
        let header = datasource.cardStack(self, headerForIndex: index, state: .expanded)
        let body = datasource.cardStack(self, viewForIndex: index, state: .expanded)
        
        
        let collapsibleStackView = CollapsibleStackViewItem([header,body], makeHeightZero: false, delegate: self)
        
        addTapGesture(view: collapsibleStackView)
        self.bodyStackView.addArrangedSubview(collapsibleStackView)
        
        guard let footer = datasource.cardStack(self, footerForIndex: index) else { return }
        self.footer = footer
        self.addArrangedSubview(footer)
        
    }
    
    public func showNextCard() {
        if (index + 1) >=  numberOfItems {
            return
        }
        
        index += 1
        guard let datasource = datasource else { return }
        let header = datasource.cardStack(self, headerForIndex: index, state: .expanded)
        let body = datasource.cardStack(self, viewForIndex: index, state: .expanded)
        self.footer?.removeFromSuperview()
        
        let collapsibleStackView = CollapsibleStackViewItem([header,body], delegate: self)
        addTapGesture(view: collapsibleStackView)
        self.bodyStackView.addArrangedSubview(collapsibleStackView)
        
        
        collapsibleStackView.state = .expanded
        let prev = self.bodyStackView.arrangedSubviews[index-1] as! CollapsibleStackViewItem
        prev.state = .partialCollapsed
        
        self.footer = datasource.cardStack(self, footerForIndex: index)
        
    }
    
    public func reloadHeader(at index: Int,shouldAnimate: Bool = true) {
        guard let newHeader = datasource?.cardStack(self, headerForIndex: index,state: self.state(for: index)) else { return }
        let container = (self.bodyStackView.arrangedSubviews[index] as! CollapsibleStackViewItem)
        let view = container.arrangedSubviews[0]
        
        
        if shouldAnimate {
            view.alpha = 1
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0
            }) { (_) in
                view.removeFromSuperview()
                container.insertArrangedSubview(newHeader, at: 0)
                newHeader.alpha = 0
                UIView.animate(withDuration: 0.2, animations: {
                    newHeader.alpha = 1
                })
            }
            
        } else {
            view.removeFromSuperview()
            container.insertArrangedSubview(newHeader, at: 0)
        }
    }
    
    public func reloadBody(at index: Int,shouldAnimate: Bool = true) {
        guard let newBody = datasource?.cardStack(self, viewForIndex: index, state: .collapsed) else { return}
        let container = (self.bodyStackView.arrangedSubviews[index] as! CollapsibleStackViewItem)
        let body = container.arrangedSubviews[1]
        body.removeFromSuperview()
        container.insertArrangedSubview(newBody, at: 1)
      
    }
    
}

//MARK:- Touch events
extension CollapsibleStackView {
    private func addTapGesture(view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.isUserInteractionEnabled = true
        view.tag = self.index
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapView(sender:UITapGestureRecognizer) {
        guard let view = sender.view, view.tag != self.index else { return }
        self.footer?.removeFromSuperview()
        index = view.tag
        
        self.footer = datasource?.cardStack(self, footerForIndex: index)
        
        
        for i in stride(from: self.bodyStackView.arrangedSubviews.count - 1, to: index, by: -1) {
            let viewToCollapse = self.bodyStackView.arrangedSubviews[i] as! CollapsibleStackViewItem
            self.collapseAnimationSync.enter()
            viewToCollapse.state = .collapsed
        }
        
        
        let viewToExpand = self.bodyStackView.arrangedSubviews[self.index] as! CollapsibleStackViewItem
        viewToExpand.state = .partialExpanded
        
        collapseAnimationSync.notify(queue: .main) {
            if let footer = self.footer {
                self.addArrangedSubview(footer)
            }
            self.delegate?.cardStack(self, didSelectItemAt: self.index)
        }

        
    }
}

//MARK:- Animation events
extension CollapsibleStackView: AnimationDelegate {
    func didFinishExpandAnimation() {
        if let footer = footer {
            self.addArrangedSubview(footer)
        }
        delegate?.cardStack(self, didSelectFooterAt: index-1)
    }
    
    func didFinishCollapseAnimation() {
        collapseAnimationSync.leave()

    }
    
}

//
//  ViewController.swift
//  Drawer container Example
//
//  Created by Viswa Kodela on 7/13/19.
//  Copyright © 2019 Viswa Kodela. All rights reserved.
//

import UIKit

class PrimaryViewController: UIViewController {
    
    // MARK: Inits
    
    // MARK:- Properties
    private var containerViewTopAnchor: NSLayoutConstraint!
    private var previousContainerViewTopConstraint: CGFloat = 0.0
    
    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDrawerViewController()
    }
    
    // MARK:- Helper Methods
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    private func configureDrawerViewController() {
        let drawerViewController = DrawerViewController()
        addChild(controller: drawerViewController)
        
        drawerViewController.delegate = self
        
        let compressedHeight = ExpansionState.height(forState: .compressed, inContatiner: view.bounds)
        let compressedTopAnchor = view.bounds.height - compressedHeight
        
        containerViewTopAnchor.constant = compressedTopAnchor
        containerViewTopAnchor.isActive = true
        previousContainerViewTopConstraint = containerViewTopAnchor.constant
    }
    
    /**
        Adds the child to the parent View
        - Parameter controller: child viewControleller you wanted to add
        */
    private func addChild(controller: UIViewController) {
        
        addChild(controller)
        guard let drawerView = controller.view else {return}
        drawerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawerView)
        drawerView.backgroundColor = .lightGray
        
        
        containerViewTopAnchor = drawerView.topAnchor.constraint(equalTo: view.topAnchor)
        drawerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        drawerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        drawerView.heightAnchor.constraint(equalToConstant: self.view.bounds.height).isActive = true
        controller.didMove(toParent: self)
    }
    
    private func animateTopConstraint(constant: CGFloat, withVelocity velocity: CGPoint) {
        let previousConstraint = previousContainerViewTopConstraint
        let distance = previousConstraint - constant
        let springVelocity = max(1 / abs(velocity.y / distance), 0.08)
        let springDamping: CGFloat = 0.6
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: springVelocity,
                       options: [.curveLinear], animations: {
                        self.containerViewTopAnchor.constant = constant
                        self.previousContainerViewTopConstraint = constant
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK:- DrawerViewController Delegate
extension PrimaryViewController: DrawerViewControllerDelegate {
    
    func drawerViewController(_ drawerViewController: DrawerViewController, didChangeTranslationPoint translationPoint: CGPoint, withVelocity velocity: CGPoint) {
        
        drawerViewController.view.isUserInteractionEnabled = false
        
        let newConstraintConstant = previousContainerViewTopConstraint + translationPoint.y
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContatiner: view.bounds)
        let fullHeightToConstraint = view.bounds.height - fullHeight
        let constraintPadding: CGFloat = 50
        
        if newConstraintConstant >= fullHeightToConstraint - (constraintPadding / 2) {
            containerViewTopAnchor.constant = newConstraintConstant
        }
    }
    
    func drawerViewController(_ drawerViewController: DrawerViewController, didEndTranslationPoint translationPoint: CGPoint, withVelocity velocity: CGPoint) {
        let compressedHeight = ExpansionState.height(forState: .compressed, inContatiner: view.bounds)
        let expandedHeight = ExpansionState.height(forState: .expanded, inContatiner: view.bounds)
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContatiner: view.bounds)
        
        let compressedTopConstrant = view.bounds.height - compressedHeight
        let expandedTopConstraint = view.bounds.height - expandedHeight
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        let constraintPadding: CGFloat = 50
        let velocityThreshold: CGFloat = 50
        drawerViewController.view.isUserInteractionEnabled = true
        
        if velocity.y > velocityThreshold {
            // Handle high velocity Pan Gesture
            if previousContainerViewTopConstraint == fullHeightTopConstraint {
                if containerViewTopAnchor.constant <= expandedTopConstraint - constraintPadding {
                    drawerViewController.expansionState = .expanded
                    animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
                } else {
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedHeight, withVelocity: velocity)
                }
            } else if previousContainerViewTopConstraint == expandedTopConstraint {
                if containerViewTopAnchor.constant <= expandedTopConstraint - constraintPadding {
                    drawerViewController.expansionState = .fullHeight
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } else {
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstrant, withVelocity: velocity)
                }
            } else {
                if containerViewTopAnchor.constant <= expandedTopConstraint - constraintPadding {
                    drawerViewController.expansionState = .fullHeight
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } else {
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstrant, withVelocity: velocity)
                }
            }
        } else {
            // Handle Low Velocity
            if containerViewTopAnchor.constant <= expandedTopConstraint - constraintPadding {
                drawerViewController.expansionState = .fullHeight
                animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
            } else if containerViewTopAnchor.constant <= compressedTopConstrant - constraintPadding {
                drawerViewController.expansionState = .compressed
                animateTopConstraint(constant: compressedTopConstrant, withVelocity: velocity)
            } else {
                drawerViewController.expansionState = .expanded
                animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
            }
        }
    }
    
    func drawerViewController(_ drawerViewController: DrawerViewController, didChangeExpansionState expansionState: ExpansionState) {
        
    }
}


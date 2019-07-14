//
//  DrawerViewController.swift
//  Drawer container Example
//
//  Created by Viswa Kodela on 7/13/19.
//  Copyright © 2019 Viswa Kodela. All rights reserved.
//

import UIKit

protocol DrawerViewControllerDelegate: class {
    /**
        Called when DrawerViewController is in the Change state
        */
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didChangeTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint)
    
    /**
        This methid will be called when the DrawerViewController is in the End State
        */
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didEndTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint)
    
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didChangeExpansionState expansionState: ExpansionState)
}

class DrawerViewController: UITableViewController {
    
    // MARK:- Init
    
    // MARK:- Properties
    private var panGesture: UIPanGestureRecognizer!
    private var shouldHandlePanGesture: Bool = true
    
    /// Current Expansion State
    var expansionState: ExpansionState = .compressed {
        didSet {
            if expansionState != oldValue {
                configure(forExpansionState: expansionState)
            }
        }
    }
    
    private lazy var searchBar = UISearchBar()
    
    weak var delegate: DrawerViewControllerDelegate?
    
    
    
    // MARK:- Lifcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        setupGestureRecognizer()
    }
    
    // MARK:- Helper Methods
    private func configureLayout() {
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 8
        
        searchBar.placeholder = "search"
        searchBar.searchBarStyle = .minimal
        searchBar.sizeToFit()
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setupGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.cancelsTouchesInView = true
        panGesture.delegate = self
        
        self.view.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
        
    }
    
    private func configure(forExpansionState expansionState: ExpansionState) {
        switch expansionState {
        case .compressed:
            tableView.panGestureRecognizer.isEnabled = false
            break
        case .expanded:
            tableView.panGestureRecognizer.isEnabled = false
            break
        case .fullHeight:
            if tableView.contentOffset.y > 0.0 {
                panGesture.isEnabled = false
            } else {
                panGesture.isEnabled = true
            }
            tableView.panGestureRecognizer.isEnabled = true
            break
        }
    }
}

// MARK:- PanGestue Action
extension DrawerViewController {
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        guard shouldHandlePanGesture else {return}
        
        let translationPoint = gesture.translation(in: view.superview)
        let velocity = gesture.velocity(in: view.superview)
        
        switch gesture.state {
        case .changed:
            delegate?.drawerViewController(self,
                                           didChangeTranslationPoint: translationPoint,
                                           withVelocity: velocity)
        case .ended:
            delegate?.drawerViewController(self,
                                           didEndTranslationPoint: translationPoint,
                                           withVelocity: velocity)
        default:
            return
        }
    }
}

// MARK:- PanGesture Delgate
extension DrawerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {return true}
        let velocity = panGestureRecognizer.velocity(in: view.superview)
        tableView.panGestureRecognizer.isEnabled = true
        
        if otherGestureRecognizer == tableView.panGestureRecognizer {
            switch expansionState {
            case .compressed:
                return false
            case .expanded:
                return false
            case .fullHeight:
                if velocity.y > 0.0 {
                    // panned down
                    print(tableView.contentOffset.y)
                    if tableView.contentOffset.y > 0.0 {
                        return true
                    }
                    shouldHandlePanGesture = true
                    tableView.panGestureRecognizer.isEnabled = true
                    return false
                } else {
                    // panned up
                    shouldHandlePanGesture = false
                    return true
                }
            }
        }
        return false
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let panGestureRecognizer = self.panGesture else {return}
        let contentOffset = scrollView.contentOffset.y
        if contentOffset <= 0.0 && expansionState == .fullHeight && panGestureRecognizer.velocity(in: view.superview).y != 0.0 {
            shouldHandlePanGesture = true
            scrollView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
        }
    }
}

// MARK:- Search Bar Delegate
extension DrawerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.drawerViewController(self, didChangeExpansionState: .fullHeight)
    }
}

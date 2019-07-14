//
//  ExpansionState.swift
//  Drawer container Example
//
//  Created by Viswa Kodela on 7/13/19.
//  Copyright © 2019 Viswa Kodela. All rights reserved.
//

import UIKit

enum ExpansionState {
    case compressed
    case expanded
    case fullHeight
    
    
    static func height(forState state: ExpansionState, inContatiner container: CGRect) -> CGFloat {
        switch state {
        case .compressed:
            return 120
        case .expanded:
            return 300
        case .fullHeight:
            return container.height - 35
        }
    }
}

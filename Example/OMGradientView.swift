//
//    Copyright 2016 - Jorge Ouahbi
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
//
//  OMGradientView.swift
//
//  Created by Jorge Ouahbi on 21/4/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//
import UIKit
// MARK: - Gradient View
open class OMGradientView<T: CALayer>: UIView {
    // MARK: - Properties
    /// The view’s conical gradient layer used for rendering. (read-only)
    open var gradientLayer: T {
        return layer as! T // swiftlint:disable:this force_cast
    }
    override open class var layerClass: AnyClass {
        return T.self as AnyClass
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    fileprivate func setup() {
        let scale =  UIScreen.main.scale
        layer.contentsScale = scale
        layer.needsDisplayOnBoundsChange = true
        layer.drawsAsynchronously = true
        layer.allowsGroupOpacity = true
        layer.shouldRasterize = true
        layer.rasterizationScale = scale
        self.backgroundColor    = UIColor.white
        layer.setNeedsDisplay()
    }
}

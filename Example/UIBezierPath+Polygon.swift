//
//  UIBezierPath+Polygon.swift
//
//  Created by Jorge Ouahbi on 12/9/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//
// Based on Erica Sadun code
// https://gist.github.com/erica/c54826fd3411d6db053bfdfe1f64ab54
import UIKit
public enum PolygonStyle: Int {
    case flatsingle, flatdouble, curvesingle, curvedouble, flattruple, curvetruple
}
public struct Bezier {
    static func polygon(
        sides sideCount: Int = 5,
        radius: CGFloat = 50.0,
        startAngle offset: CGFloat =  0.0,
        style: PolygonStyle = .curvesingle,
        percentInflection: CGFloat = 0.0) -> BezierPath {
            guard sideCount >= 3 else {
                fatalError("Bezier polygon construction requires 3+ sides")
            }
            func pointAt(_ theta: CGFloat, inflected: Bool = false, centered: Bool = false) -> CGPoint {
                let inflection = inflected ? percentInflection : 0.0
                let centeredRadius = centered ? 0.0 : radius * (1.0 + inflection)
                return CGPoint(
                    x: centeredRadius * CGFloat(cos(theta)),
                    y: centeredRadius * CGFloat(sin(theta)))
            }
            let π = CGFloat(Double.pi); let 𝜏 = 2.0 * π  // swiftlint:disable:this identifier_name
            let path = BezierPath()
            let angleMeasure = 𝜏 / CGFloat(sideCount)
            path.move(to: pointAt(0.0 + offset))
            switch (percentInflection == 0.0, style) {
            case (true, _):
                for angleMeasureStep in stride(from: 0.0, through: 𝜏, by: angleMeasure) {
                    path.addLine(to: pointAt(angleMeasureStep + offset))
                }
            case (false, .curvesingle):
                let cpθ = angleMeasure / 2.0
                for angleMeasureStep in stride(from: 0.0, to: 𝜏, by: angleMeasure) {
                    path.addQuadCurve(
                        to: pointAt(angleMeasureStep + angleMeasure + offset),
                        controlPoint: pointAt(angleMeasureStep + cpθ + offset, inflected: true))
                }
            case (false, .flatsingle):
                let cpθ = angleMeasure / 2.0
                for angleMeasureStep in stride(from: 0.0, to: 𝜏, by: angleMeasure) {
                    path.addLine(to: pointAt(angleMeasureStep + cpθ + offset, inflected: true))
                    path.addLine(to: pointAt(angleMeasureStep + angleMeasure + offset))
                }
            case (false, .curvedouble):
                let (cp1θ, cp2θ) = (angleMeasure / 3.0, 2.0 * angleMeasure / 3.0)
                for angleMeasureStep in stride(from: 0.0, to: 𝜏, by: angleMeasure) {
                    path.addCurve(
                        to: pointAt(angleMeasureStep + angleMeasure + offset),
                        controlPoint1: pointAt(angleMeasureStep + cp1θ + offset, inflected: true),
                        controlPoint2: pointAt(angleMeasureStep + cp2θ + offset, inflected: true)
                    )
                }
            case (false, .flatdouble):
                let (cp1θ, cp2θ) = (angleMeasure / 3.0, 2.0 * angleMeasure / 3.0)
                for angleMeasureStep in stride(from: 0.0, to: 𝜏, by: angleMeasure) {
                    path.addLine(to: pointAt(angleMeasureStep + cp1θ + offset, inflected: true))
                    path.addLine(to: pointAt(angleMeasureStep + cp2θ + offset, inflected: true))
                    path.addLine(to: pointAt(angleMeasureStep + angleMeasure + offset))
                }
            case (false, .flattruple):
                let (cp1θ, cp2θ) = (angleMeasure / 3.0, 2.0 * angleMeasure / 3.0)
                for angleMeasureStep in stride(from: 0.0, to: 𝜏, by: angleMeasure) {
                    path.addLine(to: pointAt(angleMeasureStep + cp1θ + offset, inflected: true))
                    path.addLine(to: pointAt(angleMeasureStep + angleMeasure / 2.0 + offset, centered: true))
                    path.addLine(to: pointAt(angleMeasureStep + cp2θ + offset, inflected: true))
                    path.addLine(to: pointAt(angleMeasureStep + angleMeasure + offset))
                }
            case (false, .curvetruple):
                let (cp1θ, cp2θ) = (angleMeasure / 3.0, 2.0 * angleMeasure / 3.0)
                for angleMeasureStep in stride(from: 0.0, to: 𝜏, by: angleMeasure) {
                    path.addQuadCurve(
                        to: pointAt(angleMeasureStep + angleMeasure / 2.0 + offset, centered: true),
                        controlPoint: pointAt(angleMeasureStep + cp1θ + offset, inflected: true))
                    path.addQuadCurve(
                        to: pointAt(angleMeasureStep + angleMeasure + offset),
                        controlPoint: pointAt(angleMeasureStep + cp2θ + offset, inflected: true))
                }
            }
            path.close()
            return path
        }
}

extension UIBezierPath {
    public class func polygon(frame: CGRect,
                              sides: Int = 5,
                              radius: CGFloat = 50.0,
                              startAngle: CGFloat =  0.0,
                              style: PolygonStyle = .curvesingle,
                              percentInflection: CGFloat = 0.0) -> UIBezierPath {
        let bezier = Bezier.polygon(
            sides: sides,
            radius: radius,
            startAngle: startAngle,
            style: style,
            percentInflection: percentInflection)
        bezier.fitPathToRect(frame)
        bezier.movePathCenterToPoint(CGPoint(x: frame.midX,y: frame.midY))
        return bezier
    }
}

func rectGetCenter(_ rect : CGRect)-> CGPoint {
    return CGPoint(x: rect.midX, y: rect.midY)
}

func sizeScaleByFactor(_ aSize: CGSize,  factor: CGFloat) -> CGSize {
    return CGSize(width: aSize.width * factor, height: aSize.height * factor)
}

func aspectScaleFit(_ sourceSize: CGSize, destRect: CGRect) -> CGFloat {
    let  destSize = destRect.size
    let scaleW = destSize.width / sourceSize.width
    let scaleH = destSize.height / sourceSize.height
    return min(scaleW, scaleH)
}


func rectAroundCenter(_ center: CGPoint, size: CGSize) -> CGRect {
    let halfWidth = size.width / 2.0
    let halfHeight = size.height / 2.0
    
    return CGRect(x:center.x - halfWidth, y:center.y - halfHeight, width: size.width, height: size.height)
}

func rectByFittingRect(sourceRect: CGRect, destinationRect: CGRect) -> CGRect {
    let aspect = aspectScaleFit(sourceRect.size, destRect: destinationRect)
    let  targetSize = sizeScaleByFactor(sourceRect.size, factor: aspect)
    return rectAroundCenter(rectGetCenter(destinationRect), size: targetSize)
}

// MARK: - UIBezierPath+polygon
extension UIBezierPath {
    func fitPathToRect( _ destRect: CGRect) {
        let bounds = self.boundingBox()
        let fitRect = rectByFittingRect(sourceRect: bounds, destinationRect: destRect)
        let scale = aspectScaleFit(bounds.size, destRect: destRect)
        let newCenter = rectGetCenter(fitRect)
        self.movePathCenterToPoint(newCenter)
        self.scalePath(sx: scale, sy:  scale)
    }
    
    func adjustPathToRect( _ destRect: CGRect) {
        let bounds = self.boundingBox()
        let scaleX = destRect.size.width / bounds.size.width
        let scaleY = destRect.size.height / bounds.size.height
        let newCenter = CGPoint(x: destRect.midX,y: destRect.midY)
        self.movePathCenterToPoint(newCenter)
        self.scalePath(sx: scaleX, sy: scaleY)
    }
    
    func applyCenteredPathTransform(_ transform: CGAffineTransform) {
        let center = self.boundingBox().size.center
        var identity = CGAffineTransform.identity
        identity = identity.translatedBy(x: center.x, y: center.y)
        identity = transform.concatenating(identity)
        identity = identity.translatedBy(x: -center.x, y: -center.y)
        self.apply(identity)
    }
    
    class func pathByApplyingTransform( _ transform: CGAffineTransform) -> UIBezierPath? {
        let copy = self.copy()
        (copy as? UIBezierPath)?.applyCenteredPathTransform(transform)
        return copy as? UIBezierPath
    }
    
    func rotatePath(_ theta: CGFloat) {
        self.applyCenteredPathTransform(CGAffineTransform(rotationAngle: theta))
    }
    
    func scalePath( sx: CGFloat, sy: CGFloat) {
        self.applyCenteredPathTransform(CGAffineTransform(scaleX: sx, y: sy))
    }
    
    func offsetPath(_ offset: CGSize) {
        self.applyCenteredPathTransform( CGAffineTransform(translationX: offset.width, y: offset.height))
    }
    
    func movePathToPoint( _ destPoint: CGPoint) {
        let bounds = self.boundingBox()
        let p1 = bounds.origin
        let p2 = destPoint
        let vector = CGSize(width: p2.x - p1.x,
                            height: p2.y - p1.y)
        self.offsetPath(vector)
    }
    
    func movePathCenterToPoint(_ destPoint: CGPoint) {
        let bounds = self.boundingBox()
        let firstPoint = bounds.origin
        let targetPoint = destPoint
        var vector = CGSize(width: targetPoint.x - firstPoint.x,
                            height: targetPoint.y - firstPoint.y)
        vector.width -= bounds.size.width / 2.0
        vector.height -= bounds.size.height / 2.0
        self.offsetPath( vector)
    }
    func boundingBox() -> CGRect {
        return self.cgPath.boundingBox
    }
}

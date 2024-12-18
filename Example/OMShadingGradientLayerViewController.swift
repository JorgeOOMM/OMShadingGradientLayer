//
//    Copyright 2015 - Jorge Ouahbi
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
import UIKit
import GUILib

let kDefaultAnimationDuration: TimeInterval = 5.0
// MARK: OMShadingGradientLayerViewController: UITableViewDataSource, UITableViewDelegate
extension OMShadingGradientLayerViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableView Helpers
    func selectIndexPath(_ row: Int, section: Int = 0) {
        let indexPath = IndexPath(item: row, section: section)
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        self.gradientLayer.slopeFunction = self.slopeFunction[(indexPath as NSIndexPath).row]
    }
    // MARK: - UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slopeFunction.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        assert(self.slopeFunctionString.count == self.slopeFunction.count)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font          = UIFont(name: "Helvetica", size: 9)
        cell.textLabel?.text          = "\(self.slopeFunctionString[(indexPath as NSIndexPath).row])"
        cell.layer.cornerRadius       = 8
        cell.layer.masksToBounds      = true
        return cell
    }
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.gradientLayer.slopeFunction = self.slopeFunction[(indexPath as NSIndexPath).row]
    }
}
// MARK: OMShadingGradientLayerViewController
class OMShadingGradientLayerViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pointStartX: UISlider!
    @IBOutlet weak var pointEndX: UISlider!
    @IBOutlet weak var pointStartY: UISlider!
    @IBOutlet weak var pointEndY: UISlider!
    @IBOutlet weak var endPointSliderValueLabel: UILabel!
    @IBOutlet weak var startPointSliderValueLabel: UILabel!
    @IBOutlet weak var viewForGradientLayer: UIView!
    @IBOutlet weak var startRadiusSlider: UISlider!
    @IBOutlet weak var endRadiusSlider: UISlider!
    @IBOutlet weak var startRadiusSliderValueLabel: UILabel!
    @IBOutlet weak var endRadiusSliderValueLabel: UILabel!
    @IBOutlet weak var typeGardientSwitch: UISwitch!
    @IBOutlet weak var extendsPastEnd: UISwitch!
    @IBOutlet weak var extendsPastStart: UISwitch!
    @IBOutlet weak var segmenFunction: UISegmentedControl!
    @IBOutlet weak var strokePath: UISwitch!
    @IBOutlet weak var randomPath: UISwitch!
    var colors: [UIColor] = []
    var locations: [CGFloat] = [0.0, 1.0]
    var subviewForGradientLayer: OMGradientView<OMShadingGradientLayer>!
    var gradientLayer: OMShadingGradientLayer = OMShadingGradientLayer(type: .radial)
    var animateGradientLayer: Bool = true
    var textLayer: OMTextLayer = OMTextLayer(string: "Hello shading", font: UIFont(name: "Helvetica", size: 50)!)
    lazy var slopeFunction: [(Double) -> Double] = {
        return [
            linear,
            quadraticEaseIn,
            quadraticEaseOut,
            quadraticEaseInOut,
            cubicEaseIn,
            cubicEaseOut,
            cubicEaseInOut,
            quarticEaseIn,
            quarticEaseOut,
            quarticEaseInOut,
            quinticEaseIn,
            quinticEaseOut,
            quinticEaseInOut,
            sineEaseIn,
            sineEaseOut,
            sineEaseInOut,
            circularEaseIn,
            circularEaseOut,
            circularEaseInOut,
            exponentialEaseIn,
            exponentialEaseOut,
            exponentialEaseInOut,
            elasticEaseIn,
            elasticEaseOut,
            elasticEaseInOut,
            backEaseIn,
            backEaseOut,
            backEaseInOut,
            bounceEaseIn,
            bounceEaseOut,
            bounceEaseInOut
        ]
    }()
    lazy var slopeFunctionString: [String] = {
        return [
            "Linear",
            "QuadraticEaseIn",
            "QuadraticEaseOut",
            "QuadraticEaseInOut",
            "CubicEaseIn",
            "CubicEaseOut",
            "CubicEaseInOut",
            "QuarticEaseIn",
            "QuarticEaseOut",
            "QuarticEaseInOut",
            "QuinticEaseIn",
            "QuinticEaseOut",
            "QuinticEaseInOut",
            "SineEaseIn",
            "SineEaseOut",
            "SineEaseInOut",
            "CircularEaseIn",
            "CircularEaseOut",
            "CircularEaseInOut",
            "ExponentialEaseIn",
            "ExponentialEaseOut",
            "ExponentialEaseInOut",
            "ElasticEaseIn",
            "ElasticEaseOut",
            "ElasticEaseInOut",
            "BackEaseIn",
            "BackEaseOut",
            "BackEaseInOut",
            "BounceEaseIn",
            "BounceEaseOut",
            "BounceEaseInOut"
        ]
    }()
    @IBAction func maskTextSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            textLayer.removeFromSuperlayer()
            gradientLayer.mask = textLayer
        } else {
            gradientLayer.mask = nil
            gradientLayer.addSublayer(textLayer)
        }
        updateGradientLayer()
    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        subviewForGradientLayer  = OMGradientView<OMShadingGradientLayer>(frame: viewForGradientLayer.frame)
        viewForGradientLayer.addSubview(subviewForGradientLayer)
        gradientLayer   = subviewForGradientLayer!.gradientLayer
        gradientLayer.addSublayer(textLayer)
        randomizeColors()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let viewBounds = viewForGradientLayer.bounds
        pointStartX.maximumValue   = 1.0
        pointStartY.minimumValue   = 0.0
        pointEndX.maximumValue     = 1.0
        pointEndY.minimumValue     = 0.0
        let startPoint = CGPoint(x: viewBounds.minX, y: viewBounds.minY) / viewBounds.size
        let endPoint   = CGPoint(x: viewBounds.minX, y: viewBounds.maxY) / viewBounds.size
        pointStartX.value = Float(startPoint.x)
        pointStartY.value = Float(startPoint.y)
        pointEndX.value   = Float(endPoint.x)
        pointEndY.value   = Float(endPoint.y)
        extendsPastEnd.isOn   = true
        extendsPastStart.isOn = true
        // radius
        endRadiusSlider.maximumValue     = 1.0
        endRadiusSlider.minimumValue     = 0
        startRadiusSlider.maximumValue   = 1.0
        startRadiusSlider.minimumValue   = 0
        startRadiusSlider.value   = 1.0
        endRadiusSlider.value     = 0
        // select the first element
        selectIndexPath(0)
        gradientLayer.frame         = viewBounds
        gradientLayer.locations     = locations
        // update the gradient layer frame
        self.gradientLayer.frame = self.viewForGradientLayer.bounds
        // text layer
        self.textLayer.frame = self.viewForGradientLayer.bounds
        viewForGradientLayer.backgroundColor = UIColor.clear
        #if DEBUG
        viewForGradientLayer.layer.borderWidth = 1.0
        viewForGradientLayer.layer.borderColor = UIColor.blackColor().CGColor
        #endif
        updateTextPointsUI()
        updateGradientLayer()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: {(animation) in
        }) {(completion) in
            // update the gradient layer frame
            self.gradientLayer.frame = self.viewForGradientLayer.bounds
        }
    }
    // MARK: - Triggered actions
    @IBAction func extendsPastStartChanged(_ sender: UISwitch) {
        gradientLayer.extendsBeforeStart = sender.isOn
    }
    @IBAction func extendsPastEndChanged(_ sender: UISwitch) {
        gradientLayer.extendsPastEnd = sender.isOn
    }
    @IBAction func gradientSliderChanged(_ sender: UISlider) {
        updateTextPointsUI()
        updateGradientLayer()
    }
    @IBAction func strokeSwitchChanged(_ sender: UISwitch) {
        if gradientLayer.path != nil {
            gradientLayer.stroke = sender.isOn
        }
        sender.isOn = gradientLayer.stroke
    }
    @IBAction func maskSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            let style = PolygonStyle(rawValue: Int.random(in: 0..<6))!
            let radius = CGFloat.random(in: 0..<1) * viewForGradientLayer.bounds.size.min
            let sides = Int.random(in: 0..<32) + 4
            let path = UIBezierPath.polygon(frame: viewForGradientLayer.bounds,
                                            sides: sides,
                                            radius: radius,
                                            startAngle: 0,
                                            style: style,
                                            percentInflection: CGFloat.random(in: 0..<1))
            gradientLayer.path  = path.cgPath
        } else {
            gradientLayer.path  = nil
            strokePath.isOn = false
        }
        updateGradientLayer()
    }
    @IBAction func typeSwitchChanged(_ sender: UISwitch) {
        self.gradientLayer.gradientType = sender.isOn ?  .radial : .axial
        updateGradientLayer()
    }
    @IBAction func functionSwitchChanged(_ sender: UISegmentedControl) {
        updateSlopeFunction(sender.selectedSegmentIndex)
        updateGradientLayer()
    }
    @IBAction func animateSwitchChanged(_ sender: UISwitch) {
        self.animateGradientLayer = sender.isOn
        updateGradientLayer()
    }
    @IBAction func randomButtonTouchUpInside(_ sender: UIButton) {
        // random points
        pointStartX.value = Float.random(in: 0..<1)
        pointStartY.value = Float.random(in: 0..<1)
        pointEndX.value   = Float.random(in: 0..<1)
        pointEndY.value   = Float.random(in: 0..<1)
        // select random slope function
        selectIndexPath(Int.random(in: 0..<tableView.numberOfRows(inSection: 0)))
        let segmentIndex = Int.random(in: 0..<segmenFunction.numberOfSegments)
        updateSlopeFunction(segmentIndex)
        segmenFunction.selectedSegmentIndex = segmentIndex
        typeGardientSwitch.isOn = Float.random(in: 0..<1) > 0.5 ? true : false
        extendsPastEnd.isOn  = Float.random(in: 0..<1) > 0.5 ? true : false
        extendsPastStart.isOn = Float.random(in: 0..<1) > 0.5 ? true : false
        if typeGardientSwitch.isOn {
            // random radius
            endRadiusSlider.value   = Float.random(in: 0..<1)
            startRadiusSlider.value = Float.random(in: 0..<1)
            // random scale CGAffineTransform
            gradientLayer.radialTransform = CGAffineTransform.randomScale()
        }
        // random colors
        randomizeColors()
        // update the UI
        updateTextPointsUI()
        // update the gradient layer
        updateGradientLayer()
    }
    func animateLayer(_ startPoint: CGPoint, _ endPoint: CGPoint, _ startRadius: Double, _ endRadius: Double) {
        let mediaTime =  CACurrentMediaTime()
        CATransaction.begin()
        gradientLayer.animateKeyPath("colors",
                                     fromValue: nil,
                                     toValue: colors as AnyObject?,
                                     beginTime: mediaTime,
                                     duration: kDefaultAnimationDuration,
                                     delegate: nil)
        gradientLayer.animateKeyPath("locations",
                                     fromValue: nil,
                                     toValue: self.locations as AnyObject?,
                                     beginTime: mediaTime,
                                     duration: kDefaultAnimationDuration,
                                     delegate: nil)
        gradientLayer.animateKeyPath("startPoint",
                                     fromValue: NSValue(cgPoint: gradientLayer.startPoint),
                                     toValue: NSValue(cgPoint: startPoint),
                                     beginTime: mediaTime,
                                     duration: kDefaultAnimationDuration,
                                     delegate: nil)
        gradientLayer.animateKeyPath("endPoint",
                                     fromValue: NSValue(cgPoint: gradientLayer.endPoint),
                                     toValue: NSValue(cgPoint: endPoint),
                                     beginTime: mediaTime,
                                     duration: kDefaultAnimationDuration,
                                     delegate: nil)
        if gradientLayer.gradientType == .radial {
            gradientLayer.animateKeyPath("startRadius",
                                         fromValue: Double(gradientLayer.startRadius) as AnyObject?,
                                         toValue: startRadius as AnyObject?,
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
            gradientLayer.animateKeyPath("endRadius",
                                         fromValue: Double(gradientLayer.endRadius) as AnyObject?,
                                         toValue: endRadius as AnyObject?,
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
        }
        CATransaction.commit()
    }
}

extension OMShadingGradientLayerViewController {
    // MARK: - Helpers
    func randomizeColors() {
        self.locations = []
        self.colors.removeAll()
        var numberOfColor = round(Float.random(in: 0..<1) * 16)
        while numberOfColor > 0 {
            if let color = UIColor.random() {
                self.colors.append(color)
                numberOfColor -= 1
            }
        }
        self.gradientLayer.colors = colors
    }
    func updateGradientLayer() {
        viewForGradientLayer.layoutIfNeeded()
        let endRadius   = Double(endRadiusSlider.value)
        let startRadius = Double(startRadiusSlider.value)
        let startPoint = CGPoint(x: CGFloat(pointStartX.value), y: CGFloat(pointStartY.value))
        let endPoint   = CGPoint(x: CGFloat(pointEndX.value), y: CGFloat(pointEndY.value))
        gradientLayer.extendsPastEnd   = extendsPastEnd.isOn
        gradientLayer.extendsBeforeStart = extendsPastStart.isOn
        gradientLayer.gradientType =  typeGardientSwitch.isOn ? .radial: .axial
        if self.animateGradientLayer {
            // allways remove all animations
            gradientLayer.removeAllAnimations()
            animateLayer(startPoint, endPoint, startRadius, endRadius)
        } else {
            gradientLayer.startPoint   = startPoint
            gradientLayer.endPoint     = endPoint
            gradientLayer.colors       = self.colors
            // gradientLayer.locations     = self.locations
            gradientLayer.startRadius   = CGFloat(startRadius)
            gradientLayer.endRadius     = CGFloat(endRadius)
            self.gradientLayer.setNeedsDisplay()
        }
    }
    func updateTextPointsUI() {
        // points text
        startPointSliderValueLabel.text =  String(format: "%.1f,%.1f", pointStartX.value, pointStartY.value)
        endPointSliderValueLabel.text   =  String(format: "%.1f,%.1f", pointEndX.value, pointEndY.value)
        // radius text
        startRadiusSliderValueLabel.text = String(format: "%.1f", Double(startRadiusSlider.value))
        endRadiusSliderValueLabel.text   = String(format: "%.1f", Double(endRadiusSlider.value))
    }
    func updateSlopeFunction(_ index: Int) {
        switch index {
        case 0:
            self.gradientLayer.function =  .linear
        case 1:
            self.gradientLayer.function =  .exponential
        case 2:
            self.gradientLayer.function =  .cosine
        default:
            self.gradientLayer.function =  .linear
            assertionFailure()
        }
    }
}

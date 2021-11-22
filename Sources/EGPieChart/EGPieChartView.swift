//
//  EGPieChartView.swift
//  EGPieChart
//
//  Copyright (c) 2021 Ethan Guan
//  https://github.com/GuanyiLL/EGPieChart

open class EGPieChartView : UIView, EGAnimatorDelegate {
    open var delegate: EGPieChartDelegate?
    
    open var dataSource: EGPieChartDataSource? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Rotation degree of chart
    open var rotation: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var _outerRadius: CGFloat = 0.0
    open var outerRadius: CGFloat {
        get {
            return _outerRadius == 0.0 ? min(bounds.width, bounds.height) / 2 : _outerRadius
        }
        set {
            _outerRadius = newValue
        }
    }
    
    open var innerRadius: CGFloat = 0.0
    
    /// Center of  pie chart
    lazy var renderCenter: CGPoint = {
        return CGPoint(x :bounds.width / 2, y: bounds.height / 2)
    }()
    
    open var drawValues = true
    /// Draw polyline and values outside or not
    open var drawOutsideValues = false
    open var drawCenter = false {
        didSet {
            if drawCenter == true && innerRadius == 0.0 {
                innerRadius = outerRadius / 2
            }
        }
    }
    open var centerFillColor = UIColor.white
    
    /// Draw chart object
    private var render: EGPieChartRender?
    
    /// Value inside position 
    @EGLimited(min:0, max:1) open var valueOffsetX: CGFloat = 0.5
    @EGLimited(min:0, max:1) open var valueOffsetY: CGFloat = 0.5
    
    /// Line&OutsideValue position control
    open var line1Persentage: CGFloat = 0.9
    open var line1Lenght: CGFloat = 20.0
    @EGLimited(min:0, max:1) open var line1AnglarOffset: CGFloat = 0.5
    open var line2Length: CGFloat = 20.0

    /// Previous point
    private var _prePoint = CGPoint.zero
    
    // MARK: Deceleration vairiables
    private var _preTime: TimeInterval = 0.0
    private var _angularVelocity: CGFloat = 0.0
    private var _decelerationDisplayLink: CADisplayLink!
    @EGLimited(min:0, max:1) private var _frictionCoeff: CGFloat = 0.9
    private struct EGAngularVelocity {
        var time: TimeInterval
        var offset: CGFloat
    }
    private var _angularVelocityStorage = [EGAngularVelocity]()
    
    // MARK: Animation
    /// The animator responsible for animating chart values.
    open internal(set) lazy var animator: EGAnimator = {
        let animator = EGAnimator()
        animator.delegate = self
        return animator
    }()
    
    open func animate(_ duration:TimeInterval) {
        render?.animator.animate(duration: duration)
    }
    
    public func animatorBegan(_ animator: EGAnimator) {
        delegate?.animationDidStart()
    }
    
    public func animatorUpdated(_ animator: EGAnimator) {
        setNeedsDisplay()
    }
    
    public func animatorStopped(_ animator: EGAnimator) {
        delegate?.animationDidStop()
    }
    
    // MARK: Touch event
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        stopDeceleration()
        _angularVelocityStorage.removeAll()
        _prePoint = touch.location(in: self)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let p = touch.location(in: self)
        let deltaAagle = calculateAnglarDisplacement(_prePoint, p)
        processVelocity(deltaAagle)
        _prePoint = p
        rotation += deltaAagle
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let p = touch.location(in: self)
        let deltaAagle = calculateAnglarDisplacement(_prePoint, p)
        processVelocity(deltaAagle)
        _angularVelocity = calculateVelocity()
        
        if _angularVelocity != 0.0 {
            _preTime = CACurrentMediaTime()
            _decelerationDisplayLink = CADisplayLink(target: self, selector: #selector(decelerationLink))
            _decelerationDisplayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        }
    }
    
    // MARK: Deceleration
    
    /// - Returns: Angle between point1 and point2
    private func calculateAnglarDisplacement(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        guard let render = render else { return 0.0 }
        let a1 = render.angleForPoint(p1)
        let a2 = render.angleForPoint(p2)
        var deltaA = a2 - a1
        // cross the xAxis
        if abs(a2 - a1) > 270.0 {
            if a1 > a2 {
                deltaA += 360.0
            } else {
                deltaA -= 360.0
            }
        }
        return deltaA
    }
    
    /// Deceleration animation
    @objc private func decelerationLink() {
        let currentTime = CACurrentMediaTime()
        // decelerate
        _angularVelocity *= _frictionCoeff
        // delta time
        let timeInterval = CGFloat(currentTime - _preTime)
        rotation += _angularVelocity * timeInterval
        _preTime = currentTime
        if(abs(_angularVelocity) < 0.001) {
            stopDeceleration()
        }
    }
    
    /// Maintain velocities of moving points
    private func processVelocity(_ angleOffset: CGFloat) {
        guard angleOffset != 0 else { return }
        
        let time = CACurrentMediaTime()
        let current = EGAngularVelocity(time: time, offset: angleOffset)
        
        if var last = _angularVelocityStorage.last, last.offset * angleOffset < 0 {
            _angularVelocityStorage.removeAll()
            last.offset = -last.offset
            _angularVelocityStorage.append(last)
        }
        
        var i = 0, count = _angularVelocityStorage.count
        while (i < count - 2) {
            if current.time - _angularVelocityStorage[i].time > 1.0 {
                _angularVelocityStorage.remove(at: 0)
                i -= 1
                count -= 1
            } else {
                break
            }
            i += 1
        }
        _angularVelocityStorage.append(current)
    }
    
    /// Calculate velocity based on stored points
    private func calculateVelocity() -> CGFloat {
        guard let first = _angularVelocityStorage.first,
              let last = _angularVelocityStorage.last
        else { return 0 }
        
        let deltaTime = max(0.1 ,CGFloat(last.time - first.time))
        let angle = _angularVelocityStorage.reduce(0) {
            $0 + $1.offset
        }
        let velocity = angle / deltaTime

        return velocity
    }
    
    /// Stop deceleration animation
    open func stopDeceleration() {
        if _decelerationDisplayLink !== nil {
            _decelerationDisplayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
            _decelerationDisplayLink = nil
        }
    }
    
    // MARK: Draw
    open override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        let optionContext = UIGraphicsGetCurrentContext()
        guard let context = optionContext, let render = render else { return }
        render.drawSlices(context)
        if drawValues {
            render.drawValues(context)
        }
        if drawOutsideValues {
            render.drawOutsideValues(context)
        }
        if dataSource?.centerAttributeString != nil {
            render.drawCenter(context)
        }
    }
    
    // MARK: Lifecycle
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public convenience init(dataSource: EGPieChartDataSource) {
        self.init()
        self.dataSource = dataSource
    }
    
    func config() {
        render = EGPieChartRender(self, animator)
        backgroundColor = .clear
    }
    
    deinit {
        stopDeceleration()
    }
}

extension FloatingPoint {
    var toRadian: Self {
        return self * .pi / 180
    }

    var toDegree: Self {
        return self * 180 / .pi
    }
}

public protocol EGPieChartDelegate: AnyObject {
    /// Called when the animation begins its active duration.
    func animationDidStart()
    
    /// Called when the animation either completes its active duration
    func animationDidStop()
}

@propertyWrapper
public struct EGLimited<T: Comparable> {
    let max: T
    let min: T
    var value: T
    
    public init(wrappedValue: T, min: T, max: T) {
        self.max = max
        self.min = min
        self.value = wrappedValue
    }
    
    public var wrappedValue: T {
        get { return value }
        set {
            if newValue < min {
                value = min
            } else if newValue > max {
                value = max
            } else {
                value = newValue
            }
        }
    }
}

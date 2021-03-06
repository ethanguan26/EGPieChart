//
//  EGPieChartDataSource.swift
//  EGPieChart
//
//  Copyright (c) 2021 Ethan Guan
//  https://github.com/GuanyiLL/EGPieChart

public enum EGChartPart {
    case inside
    case outside
    case all
}

open class EGPieChartDataSource
: ExpressibleByArrayLiteral
, CustomStringConvertible {
    
    public typealias ArrayLiteralElement = EGPieChartData

    /// Pie chart datas
    open var datas: [EGPieChartData]
    
    /// Perentage of single every single slice
    open var persents: [CGFloat]
    
    /// All data sum
    open var totalValue: CGFloat = 0.0
    
    /// Fill color of every single slice
    open var fillColors = [UIColor]()
    
    /// Degree of every slice
    public var drawAngles = [CGFloat]()
    
    /// Degree of every slice
    public var sliceAngles = [CGFloat]()
    
    /// Center  content
    open var centerAttributeString: NSAttributedString?
    
    public var description: String {
        return {
            var des = ""
            forEach { des += "value: \($0.value) content: \($0.content ?? "") highlighted: \($0.isHighlighted) \n"}
            return des
        }()
    }
    
    
    required convenience public init(arrayLiteral elements: EGPieChartData...) {
        self.init(datas: elements)
    }
    
    public init(datas: [EGPieChartData]) {
        let t = datas
            .map{ $0.value }
            .reduce(0, +)
        totalValue = t
        persents = datas.map{ $0.value / t }
        
        drawAngles = [CGFloat]()
        sliceAngles = [CGFloat]()
    
        var angle: CGFloat = 0.0
        for i in 0..<persents.count {
            angle += persents[i] * 360.0
            sliceAngles.append(persents[i] * 360.0)
            drawAngles.append(angle)
        }
        
        self.datas = datas
    }
    
    public func setAllValueFont(_ font: UIFont, _ part: EGChartPart = .all) {
        switch  part {
        case .inside:
            forEach { $0.valueFont = font }
        case .outside:
            forEach { $0.outsideValueFont = font }
        case .all:
            forEach { $0.valueFont = font; $0.outsideValueFont = font }
        }
    }
    
    public func setAllValueTextColor(_ color: UIColor, _ part: EGChartPart = .all) {
        switch  part {
        case .inside:
            forEach { $0.valueTextColor = color }
        case .outside:
            forEach { $0.outsideValueTextColor = color }
        case .all:
            forEach { $0.valueTextColor = color; $0.outsideValueTextColor = color }
        }
    }
    
    
}

extension EGPieChartDataSource : MutableCollection {
    public typealias Index = Int
    public typealias Element = EGPieChartData

    public var startIndex: Index {
        return datas.startIndex
    }

    public var endIndex: Index {
        return datas.endIndex
    }

    public func index(after: Index) -> Index {
        return datas.index(after: after)
    }

    public subscript(idx: Index) -> Element {
        get { return datas[idx] }
        set { self.datas[idx] = newValue }
    }
}

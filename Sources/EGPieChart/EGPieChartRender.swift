//
//  EGPieChartRender.swift
//  EGPieChart
//
//  Copyright (c) 2021 Ethan Guan
//  https://github.com/GuanyiLL/EGPieChart

import CoreGraphics

open class EGPieChartRender {
    open weak var chartView: EGPieChartView?
    let animator: EGAnimator
    
    public init(_ chart: EGPieChartView, _ animator: EGAnimator) {
        self.chartView = chart
        self.animator = animator
    }
    
    open func drawSlices(_ context: CGContext) {
        guard let chart = chartView, let datas = chart.dataSource, datas.count > 0 else { return }
        let outerRadius = chart.outerRadius
        let innerRadius = chart.innerRadius
        let rotation = chart.rotation
        
        context.saveGState()
        defer { context.restoreGState() }
        
        for i in 0..<datas.count {
            let startAngle = rotation.toRadian + (datas.drawAngles[i] - datas.sliceAngles[i]).toRadian * animator.animationProgress
            let sweepAngle = datas.sliceAngles[i].toRadian
            
            var center = chart.renderCenter
            if datas[i].isHighlighted {
                let centerOffset: CGFloat = datas.count == 1 ? 0.0 : datas[i].highlightedOffset
                center = CGPoint(x: center.x + centerOffset * cos(startAngle + sweepAngle / 2),
                                 y: center.y + centerOffset * sin(startAngle + sweepAngle / 2))
            }
            
            let innerArcStartPoint = CGPoint(x: center.x + innerRadius * cos(startAngle + sweepAngle),
                                             y: center.y + innerRadius * sin(startAngle + sweepAngle))
            
            let innerArcEndPoint = CGPoint(x: center.x +  innerRadius * cos(startAngle),
                                           y: center.y +  innerRadius * sin(startAngle))
            
            context.move(to: innerArcEndPoint)
            
            // In a flipped coordinate system (the default for UIView drawing methods in iOS), specifying a clockwise arc results in a counterclockwise arc after the transformation is applied.
            // https://developer.apple.com/documentation/coregraphics/cgcontext/2427129-addarc
            context.addArc(center: center,
                           radius: outerRadius,
                           startAngle: startAngle,
                           endAngle: startAngle + sweepAngle,
                           clockwise: false)
            context.addLine(to: innerArcStartPoint)
            context.addArc(center: center,
                           radius: innerRadius,
                           startAngle: startAngle + sweepAngle,
                           endAngle: startAngle,
                           clockwise: true)
            //            context.closePath()   // It seems not necessary
            context.setStrokeColor(datas.fillColors[i].cgColor)
            context.setFillColor(datas.fillColors[i].cgColor)
            context.drawPath(using: .fill)
        }
    }
    
    open func drawValues(_ context: CGContext) {
        guard let chart = chartView, let datas = chart.dataSource, datas.count > 0 else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        let center = chart.renderCenter
        let outerRadius = chart.outerRadius
        let innerRadius = chart.innerRadius
        
        for i in 0..<datas.count {
            let sweepAngle = datas.sliceAngles[i] * (1 - chart.valueOffsetX)
            let valueText = NSString(string: datas[i].content ?? String(format: "%.2f%%", datas.persents[i] * 100))
            let attributes: [NSAttributedString.Key: Any] = [.font: datas[i].valueFont, .foregroundColor: datas[i].valueTextColor]
            let size = valueText.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).size
            var r: CGFloat = innerRadius + (outerRadius - innerRadius) * chart.valueOffsetY
            if datas[i].isHighlighted {
                r += datas[i].highlightedOffset
            }
            
            let targetAngle = chart.rotation + (datas.drawAngles[i] - sweepAngle) * animator.animationProgress
            let targetX = center.x + r * cos(targetAngle.toRadian)
            let targetY = center.y + r * sin(targetAngle.toRadian)
            let p = CGPoint(x: targetX, y: targetY)
            
            valueText.draw(
                at: CGPoint(x: p.x - size.width / 2, y: p.y - size.height / 2),
                withAttributes: attributes)
        }
    }
    
    open func drawOutsideValues(_ context: CGContext) {
        guard let chart = chartView, let datas = chart.dataSource, datas.count > 0 else { return }
        let center = chart.renderCenter
        let outerRadius = chart.outerRadius
        
        context.saveGState()
        defer { context.restoreGState() }
        
        for i in 0..<datas.count {
            
            let sweepAngle = datas.sliceAngles[i] * (1 - chart.line1AnglarOffset)
            
            let value = NSString(string: datas[i].outsideContent ?? String(format: "%.2f", datas[i].value))
            
            let attributes: [NSAttributedString.Key: Any] = [.font: datas[i].outsideValueFont, .foregroundColor: datas[i].outsideValueTextColor]
            
            let size = value.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).size
            
            var r = outerRadius * chart.line1Persentage
            
            if datas[i].isHighlighted {
                r += datas[i].highlightedOffset
            }
            
            let line1Length = chart.line1Lenght
            var line2Length = chart.line2Length
            
            let targetAngle = (chart.rotation + (datas.drawAngles[i] - sweepAngle) * animator.animationProgress).toRadian
            var targetX = center.x + r * cos(targetAngle)
            var targetY = center.y + r * sin(targetAngle)
            let line1StartPoint = CGPoint(x: targetX, y: targetY)
            
            r += line1Length
            targetX = center.x + r * cos(targetAngle)
            targetY = center.y + r * sin(targetAngle)
            let line1EndPoint = CGPoint(x: targetX, y: targetY)
            
            var line2EndPoint = CGPoint.zero
            var textPosition: CGPoint
            
            if (line1EndPoint.x < center.x) {
                if (line1EndPoint.x - size.width - line2Length < 0) {
                    line2Length = max(0 ,line1EndPoint.x - size.width)
                }
                line2EndPoint = CGPoint(x: line1EndPoint.x - line2Length, y: line1EndPoint.y)
                textPosition = CGPoint(x: line2EndPoint.x - size.width, y: line2EndPoint.y - size.height / 2)
            } else {
                if (line1EndPoint.x + line2Length + size.width > chart.bounds.width) {
                    line2Length = max(0, chart.frame.width - size.width - line1EndPoint.x)
                }
                line2EndPoint = CGPoint(x: line1EndPoint.x + line2Length, y: line1EndPoint.y)
                textPosition = CGPoint(x: line2EndPoint.x , y: line2EndPoint.y - size.height / 2)
            }
            context.move(to: line1StartPoint)
            context.addLine(to: line1EndPoint)
            context.addLine(to: line2EndPoint)
            context.drawPath(using: .stroke)
            value.draw(at: textPosition, withAttributes: attributes)
        }
    }
    
    open func drawCenter(_ context: CGContext) {
        guard let chart = chartView, let datas = chart.dataSource, datas.count > 0 else { return }
        let center = chart.renderCenter
        let r = chart.innerRadius
        
        context.saveGState()
        defer { context.restoreGState() }
        
        let centerRect = CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
        
        context.addEllipse(in: centerRect)
        context.setFillColor(chart.centerFillColor.cgColor)
        context.drawPath(using: .fill)
        
        guard let centerText = datas.centerAttributeString else {
            return
        }
        
        let size = centerText.boundingRect(with: centerRect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let position = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        centerText.draw(at: position)
    }
    
    open func angleForPoint(_ p: CGPoint) -> CGFloat {
        guard let chart = chartView else { return 0 }
        let c = chart.renderCenter
        let x = p.x - c.x
        let y = p.y - c.y
        let length = sqrt(x * x + y * y)
        let r = acos(y / length)
        var angle = r.toDegree
        if p.x > c.x {
            angle = 360.0 - angle
        }
        // add 90° to adjust coordinate system
        
        angle = angle + 90.0
        return CGFloat(angle)
    }
}

//
//  UIDial.swift
//  UIDial
//
//  Created by Thomas Harrison on 6/29/21.
//

import UIKit

open class DecimalDial: UIDial {
    
    override open var absZeroValue: Double { 25 }
    
    override open var ticks: [Tick] {
        [
            Tick(n: 10, length: 0.2),
            Tick(n: 20, length: 0.15),
            Tick(n: 100, length: 0.1),
        ]
    }
    
    override open var tickLabels: [TickLabel] {
        (0...9).map { i in
            TickLabel(value: Double(i * 10), text: String(format: "%d", i * 10))
        }
    }
    
    override open func angle(for value: Double) -> Double {
        value * Double.pi * 2 / 100
    }
    
    override open func angleText(for value: Double) -> String {
        String(format: "%d", Int(value))
    }
}

open class DegreesDial: UIDial {
    
    override open var ticks: [Tick] {
        [
            Tick(n: 4, length: 0.2),
            Tick(n: 36, length: 0.15),
            Tick(n: 36 * 2, length: 0.1),
        ]
    }
    
    override open var tickLabels: [TickLabel] {
        [
            TickLabel(value: 0, text: "0"),
            TickLabel(value: 90, text: "90"),
            TickLabel(value: 180, text: "180"),
            TickLabel(value: 270, text: "270"),
        ]
    }
    
    override open func angle(for value: Double) -> Double {
        -value * Double.pi * 2 / 360
    }
    
    override open func angleText(for value: Double) -> String {
        String(format: "%d°", Int(value))
    }
}

open class RadiansDial: UIDial {
    
    override open var ticks: [Tick] {
        [
            Tick(n: 4, length: 0.2),  // 90°
            Tick(n: 8, length: 0.15),
            Tick(n: 12, length: 0.1),
        ]
    }
    
    override open var tickLabels: [TickLabel] {
        [
            TickLabel(value: 0, text: "0"),
            TickLabel(value: Double.pi / 2, text: "π/2"),
            TickLabel(value: Double.pi, text: "π"),
            TickLabel(value: 3 * Double.pi / 2, text: "3π/2"),
        ]
    }
}

public struct Tick {
    public var n: Int
    public var length: Double
}

public struct TickLabel {
    public var value: Double
    public var text: String
    public var radius: Double = 0.6
}

@IBDesignable open class UIDial: UIView {
    
    @IBInspectable open var label: String = "Label" { didSet { setNeedsDisplay() } }
    @IBInspectable open var value: Double = 0.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable open var centerSize: Double = 2.0
    @IBInspectable open var strokeWidth: CGFloat = 1
    @IBInspectable open var fillColor: UIColor = UIColor.systemBackground
    @IBInspectable open var strokeColor: UIColor = UIColor.systemGray2
    @IBInspectable open var labelColor: UIColor = UIColor.secondaryLabel
    @IBInspectable open var labelFont: UIFont = UIFont.systemFont(ofSize: 12.0)
    
    open var absZeroValue: Double { 0 }
    
    open var ticks: [Tick] {
        [
            Tick(n: 4, length: 0.2),
        ]
    }
    
    open var tickLabels: [TickLabel] {
        [
            TickLabel(value: 0, text: "0"),
        ]
    }
    
    open var zeroAngle: Double { angle(for: absZeroValue) }
    
    open func angle(for value: Double) -> Double {
        -value // CCW
    }
    
    open func angleText(for value: Double) -> String {
        String(format: "%.3f", value)
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: 128, height: 128)
    }
    
    override open func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let rectangle = bounds.insetBy(dx: strokeWidth / 2,
                                       dy: strokeWidth / 2)
        
        context.setFillColor(fillColor.cgColor)
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(strokeWidth)
        
        // draw background
        context.fillEllipse(in: rectangle)
        
        // draw outline
        context.strokeEllipse(in: rectangle)
        
        func drawLine(angle: Double, length: Double) {
            let angle = CGFloat(angle)
            let length = 1.0 - CGFloat(length)
            let path = UIBezierPath()
            path.lineWidth = strokeWidth
            
            let center = CGPoint(x: rect.width / 2,
                                 y: rect.height / 2)
            let size = CGPoint(x: rectangle.width / 2,
                               y: rectangle.height / 2)
            let offset = CGPoint(x: cos(angle) * size.x,
                                 y: sin(angle) * size.y)
            
            let origin = CGPoint(x: center.x + offset.x * length,
                                 y: center.y + offset.y * length)
            path.move(to: origin)
            
            let end = CGPoint(x: center.x + offset.x,
                              y: center.y + offset.y)
            path.addLine(to: end)
            
            path.stroke()
        }
        
        func ticks(n: Int, length: Double) {
            for i in 0...n {
                let i = Double(i)
                let n = Double(n)
                let angle = i * Double.pi / (n / 2)
                drawLine(angle: angle - zeroAngle, length: length)
            }
        }
        
        func drawText(text: String, y: Double) {
            let y = CGFloat(y)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: labelFont,
                .foregroundColor: labelColor,
            ]
            let attributedString = NSAttributedString(string: text,
                                                      attributes: attributes)
            
            let stringRect = CGRect(x: rect.width / 2 - 50,
                                    y: rect.height / 2 + y,
                                    width: 100,
                                    height: rect.height)
            
            attributedString.draw(in: stringRect)
        }
        
        func drawText(text: String, for value: Double = 0, radius: Double = 0.5) {
            let angle = CGFloat(angle(for: value) - zeroAngle)
            let radius = CGFloat(radius)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: labelFont,
                .foregroundColor: labelColor,
            ]
            let attributedString = NSAttributedString(string: text,
                                                      attributes: attributes)
            
            let center = CGPoint(x: rect.width / 2,
                                 y: rect.height / 2)
            let size = CGPoint(x: rectangle.width / 2,
                               y: rectangle.height / 2)
            let offset = CGPoint(x: cos(angle) * size.x,
                                 y: sin(angle) * size.y)
            
            let origin = CGPoint(x: center.x + offset.x * radius,
                                 y: center.y + offset.y * radius)
            
            let stringSize = attributedString.size()
            let stringRect = CGRect(x: origin.x - stringSize.width / 2,
                                    y: origin.y - stringSize.height / 2,
                                    width: stringSize.width,
                                    height: stringSize.height)
            
            attributedString.draw(in: stringRect)
        }
        
        for tick in self.ticks {
            ticks(n: tick.n, length: tick.length)
        }
        
        drawText(text: label, y: -25)
        drawText(text: angleText(for: value), y: 5)
        
        for tickLabel in self.tickLabels {
            drawText(text: tickLabel.text, for: tickLabel.value, radius: tickLabel.radius)
        }
        
        // draw indicator line
        if value == 0 {
            context.setStrokeColor(UIColor.systemGreen.cgColor)
        } else {
            context.setStrokeColor(UIColor.systemRed.cgColor)
        }
        drawLine(angle: angle(for: value) - zeroAngle, length: 1.0)
        
        // draw center dot
        if centerSize > 0 {
            context.setFillColor(strokeColor.cgColor)
            context.fillEllipse(in: rectangle.insetBy(dx: rectangle.width / 2 - CGFloat(centerSize), dy: rectangle.height / 2 - CGFloat(centerSize)))
        }
    }
}

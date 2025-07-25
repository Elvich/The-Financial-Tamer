//
//  PieChartView.swift
//  Utilities
//
//  Created by Maksim Gritsuk on 25.07.2025.
//

import Foundation
import UIKit

public class PieChartView: UIView {
    
    // MARK: - Properties
    
    public var entities: [Entity] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let lineWidth: CGFloat = 12 // Толщина кольца
    
    // MARK: - Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    // MARK: - Drawing
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !entities.isEmpty else { return }
        
        let processedData = processEntities()
        drawRingChart(with: processedData, in: rect)
    }
    
    // MARK: - Data Processing
    
    private func processEntities() -> [Entity] {
        guard entities.count > 5 else { return entities }
        
        var result = Array(entities.prefix(5))
        let remainingEntities = entities.suffix(from: 5)
        let remainingSum = remainingEntities.reduce(Decimal(0)) { $0 + $1.value }
        
        if remainingSum > 0 {
            let otherEntity = Entity(value: remainingSum, label: "Остальные")
            result.append(otherEntity)
        }
        
        return result
    }
    
    // MARK: - Ring Chart Drawing
    
    private func drawRingChart(with data: [Entity], in rect: CGRect) {
        guard !data.isEmpty else { return }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2
        let totalValue = data.reduce(Decimal(0)) { $0 + $1.value }
        
        guard totalValue > 0 else { return }
        
        var currentAngle: CGFloat = -.pi / 2 // Начинаем с верхней точки
        let circlePath = UIBezierPath()
        
        // Рисуем сегменты кольца
        for (index, entity) in data.enumerated() {
            let percentage = CGFloat((entity.value as NSDecimalNumber).doubleValue / (totalValue as NSDecimalNumber).doubleValue)
            let angle = CGFloat.pi * 2 * percentage
            
            // Получаем цвет для сегмента
            let color = PieChartColors.colors[index % PieChartColors.colors.count]
            
            // Создаем сегмент кольца
            let path = createRingSegmentPath(
                center: center,
                radius: radius,
                startAngle: currentAngle,
                endAngle: currentAngle + angle,
                lineWidth: lineWidth
            )
            
            color.setFill()
            path.fill()
            
            currentAngle += angle
        }
        
        // Рисуем текст по центру
        drawCenterText(total: totalValue, in: rect)
    }
    
    private func createRingSegmentPath(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, lineWidth: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        // Внешний радиус
        let outerRadius = radius + lineWidth / 2
        // Внутренний радиус
        let innerRadius = radius - lineWidth / 2
        
        // Внешняя дуга (против часовой стрелки)
        path.addArc(
            withCenter: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true // Против часовой стрелки
        )
        
        // Линия к внутренней дуге
        let outerEnd = CGPoint(
            x: center.x + cos(endAngle) * outerRadius,
            y: center.y + sin(endAngle) * outerRadius
        )
        let innerEnd = CGPoint(
            x: center.x + cos(endAngle) * innerRadius,
            y: center.y + sin(endAngle) * innerRadius
        )
        path.addLine(to: innerEnd)
        
        // Внутренняя дуга (в обратном направлении)
        path.addArc(
            withCenter: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: false // По часовой стрелке
        )
        
        // Линия к началу внешней дуги
        let innerStart = CGPoint(
            x: center.x + cos(startAngle) * innerRadius,
            y: center.y + sin(startAngle) * innerRadius
        )
        path.addLine(to: innerStart)
        
        path.close()
        return path
    }
    
    private func drawCenterText(total: Decimal, in rect: CGRect) {
        guard !entities.isEmpty else { return }
        
        let totalValue = NSDecimalNumber(decimal: total).doubleValue
        let totalString = String(format: "%.2f", totalValue)
        
        // Определяем валюту (берем из первой транзакции)
        let currencySymbol = "₽" // Заглушка, в реальности нужно брать из данных
        
        let fullText = "\(totalString)\n\(currencySymbol)"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ]
        
        let textSize = fullText.boundingRect(
            with: CGSize(width: rect.width, height: rect.height),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        ).size
        
        let textRect = CGRect(
            x: rect.midX - textSize.width / 2,
            y: rect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        fullText.draw(in: textRect, withAttributes: attributes)
    }
}

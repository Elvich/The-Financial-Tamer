//
//  PieChartView.swift
//  Utilities
//
//  Created by Maksim Gritsuk on 25.07.2025.
//
import UIKit

public class PieChartView: UIView {
    
    // MARK: - Properties
    
    public var entities: [Entity] = [] {
        didSet {
            animateChart(reverse: true) {
                self.animateChart(reverse: false)
            }
        }
    }
    
    private var lineWidth: CGFloat = 12 // Толщина кольца
    
    private var progressAngle: CGFloat = 0 { // Начальное значение 0
        didSet {
            setNeedsDisplay() // Это перерисует view
        }
    }
    
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
        
        let processedData = processEntities() // Обрабатываем данные внутри PieChartView
        drawRingChart(with: processedData, in: rect)
        drawCenterText(for: processedData, in: rect) // Передаем обработанные данные
    }
    
    public func animateChart(reverse: Bool = false, completion: (() -> Void)? = nil) {
        let startProgress: CGFloat = reverse ? 2 : 0
        
        progressAngle = startProgress
        //setNeedsDisplay()
        
        if reverse {
            // Быстрая очистка
            //lineWidth = 12
            setNeedsDisplay()
            
            animateStep(reverse: reverse, duration: 0.008, completion: completion)
        } else {
            // Нормальное заполнение с анимацией толщины
            lineWidth = 4
            setNeedsDisplay()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.animateStep(reverse: reverse, duration: 0.008) {
                    completion?()
                }
            }
        }
    }

    private func animateStep(reverse: Bool, duration: TimeInterval, completion: (() -> Void)?) {
        let totalSteps = 120
        let delay = duration / Double(totalSteps)
        
        func animateStepInternal(currentStep: Int) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(currentStep) * delay) {
                let progress = (CGFloat(currentStep) / CGFloat(totalSteps)) * 2
                self.progressAngle = reverse ? (2.0 - progress) : progress
                self.lineWidth = reverse ? 12 - (6 * progress) : 6 * progress
                self.setNeedsDisplay()
                
                if currentStep < totalSteps {
                    animateStepInternal(currentStep: currentStep + 1)
                } else {
                    completion?()
                }
            }
        }
        
        animateStepInternal(currentStep: 0)
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
        let progressAngle:CGFloat = self.progressAngle
        
        guard totalValue > 0 else { return }
        
        var currentAngle: CGFloat = -.pi/2  // Начинаем с верхней точки (по часовой стрелке)
        
        for (index, entity) in data.enumerated() {
            let percentage = CGFloat((entity.value as NSDecimalNumber).doubleValue / (totalValue as NSDecimalNumber).doubleValue)
            let angle = -CGFloat.pi * progressAngle  * percentage
            
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
    }
    
    private func createRingSegmentPath(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, lineWidth: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        // Внешний радиус
        let outerRadius = radius + lineWidth / 2
        // Внутренний радиус
        let innerRadius = radius - lineWidth / 2
        
        // Внешняя дуга (по часовой стрелке)
        path.addArc(
            withCenter: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
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
            clockwise: true
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
    
    // MARK: - Center Text Drawing
    
    private func drawCenterText(for displayedEntities: [Entity], in rect: CGRect) {
        guard !displayedEntities.isEmpty else { return }
        
        let totalValue = displayedEntities.reduce(Decimal(0)) { $0 + $1.value }
        guard totalValue > 0 else { return }
        
        let fullText = NSMutableAttributedString()
        
        // Определяем максимальное количество строк, которые могут поместиться
        // Примерно 3-4 строки в центре кольца -- можно настроить
        let maxLinesToShow = min(5, displayedEntities.count)
        
        for (index, entity) in displayedEntities.prefix(maxLinesToShow).enumerated() {
            if index > 0 {
                fullText.append(NSAttributedString(string: "\n")) // Перевод строки между категориями
            }
            
            // Рассчитываем процент
            let percentageValue = (entity.value as NSDecimalNumber).doubleValue / (totalValue as NSDecimalNumber).doubleValue
            let percentageString = String(format: "%.0f%%", percentageValue * 100)
            
            // Получаем цвет для категории
            let colorIndex = index % PieChartColors.colors.count
            let color = PieChartColors.colors[colorIndex]
            
            // 1. Добавляем цветную точку
            let dotAttachment = TextAttachment()
            dotAttachment.color = color
            // Размер точки адаптируется под шрифт
            let fontSize: CGFloat = 12.0
            dotAttachment.bounds = CGRect(x: 0, y: -1, width: fontSize * 0.6, height: fontSize * 0.6)
            
            let dotString = NSAttributedString(attachment: dotAttachment)
            fullText.append(dotString)
            fullText.append(NSAttributedString(string: " ")) // Пробел после точки
            
            // 2. Добавляем название категории и процент
            // Ограничиваем длину названия категории, если нужно
            let maxLabelLength = 12
            let categoryName = entity.label.count > maxLabelLength ? String(entity.label.prefix(maxLabelLength)) + "..." : entity.label
            
            let combinedString = "\(categoryName) \(percentageString)"
            let combinedAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: UIColor.label
            ]
            fullText.append(NSAttributedString(string: combinedString, attributes: combinedAttributes))
        }
        
        // Если есть еще категории, не помещающиеся в maxLinesToShow, добавим "+N"
        if displayedEntities.count > maxLinesToShow {
            let remainingCount = displayedEntities.count - maxLinesToShow
            fullText.append(NSAttributedString(string: "\n+\(remainingCount) \(displayedEntities.count > maxLinesToShow + 1 ? "категорий" : "категория")", attributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .light),
                .foregroundColor: UIColor.secondaryLabel
            ]))
        }
        
        // Рассчитываем размер и позицию для отрисовки
        // Ограничиваем размер текста, чтобы он помещался внутри кольца
        let maxTextWidth = min(rect.width, rect.height) * 0.6 // ~60% от меньшей стороны
        let maxTextHeight = min(rect.width, rect.height) * 0.6
        
        let maxSize = CGSize(width: maxTextWidth, height: maxTextHeight)
        let textSize = fullText.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        let textRect = CGRect(
            x: rect.midX - textSize.width / 2,
            y: rect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        // Отрисовываем текст
        fullText.draw(in: textRect)
    }
}

// MARK: - Text Attachment Helper
private class TextAttachment: NSTextAttachment {
    var color: UIColor = .black
    
    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        let size = imageBounds.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            color.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
        return image
    }
}

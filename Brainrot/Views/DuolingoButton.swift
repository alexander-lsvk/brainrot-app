//
//  DuolingoButton.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 19.11.25.
//

import SwiftUI

struct DuolingoButton: View {
    let title: String
    let color: Color
    
    @State private var isPressed = false
    @State private var hapticTrigger = false
    
    private var offsetY: CGFloat {
        isPressed ? 0 : -8
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(color.opacity(0.7))
                .frame(height: 60)
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(color)
                .frame(height: 60)
                .offset(y: offsetY)
                .overlay(
                    Text(title)
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .offset(y: offsetY)
                )
                .onTapGesture {
                    hapticTrigger.toggle()
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.spring(.snappy(duration: 0.05))) {
                                isPressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(.snappy(duration: 0.05))) {
                                isPressed = false
                            }
                        }
                )
        }
        .sensoryFeedback(.selection, trigger: hapticTrigger)
    }
}

struct PressableButtonStyle: ButtonStyle {

    // MARK: - Shape Type
    enum ShapeType {
        case rectangle
        case ellipse
    }

    // MARK: - Properties
    private let foregroundColor: Color
    private let backgroundColor: Color
    private let shape: ShapeType
    private var cornerRadius: CGFloat = 0
    private var yOffset: CGFloat = 0

    // MARK: - Initializers

    /// Rectangle Version
    init(
        foregroundColor: Color,
        backgroundColor: Color,
        cornerRadius: CGFloat,
        yOffset: CGFloat = 8
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shape = .rectangle
        self.yOffset = yOffset
    }

    /// Ellipse / Circle Version
    init(
        foregroundColor: Color,
        backgroundColor: Color,
        yOffset: CGFloat = 8
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.shape = .ellipse
        self.yOffset = yOffset
    }

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            buttonShape(color: backgroundColor)
            buttonShape(color: foregroundColor)
                .offset(y: configuration.isPressed ? 0 : -yOffset)
            configuration.label
                .foregroundStyle(backgroundColor)
                .offset(y: -yOffset)
                .offset(y: configuration.isPressed ? yOffset : 0)
        }
        .onChange(of: configuration.isPressed) { _, isPressed in
            if isPressed {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }

    // MARK: - Shape Builder

    @ViewBuilder
    private func buttonShape(color: Color) -> some View {
        switch shape {
        case .rectangle:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)

        case .ellipse:
            Ellipse()
                .fill(color)
        }
    }
}


#Preview {
    VStack {
        DuolingoButton(title: "Continue", color: .green)
            .padding()
        
        Button {
            
        } label: {
            Text("Continue")
                .foregroundStyle(.white)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
        }
        .buttonStyle(
            PressableButtonStyle(
                foregroundColor: .green,
                backgroundColor: .green.opacity(0.7),
                cornerRadius: 16
            )
        )
        .frame(width: 200, height: 60)
    }
}

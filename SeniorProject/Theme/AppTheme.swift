import SwiftUI

struct AppTheme {
    // MARK: - Colors
    static let primary = Color(hex: "6B4EFF") // Vibrant purple
    static let secondary = Color(hex: "FF6B6B") // Coral accent
    static let accent = Color(hex: "4ECDC4") // Teal accent
    
    static let background = Color(hex: "F8F9FA") // Light background
    static let surface = Color.white // Card background
    
    static let textPrimary = Color(hex: "2D3436") // Dark text
    static let textSecondary = Color(hex: "636E72") // Secondary text
    static let textTertiary = Color(hex: "B2BEC3") // Tertiary text
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary, Color(hex: "8B7AFF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [background, Color(hex: "FFFFFF")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Shadows
    static let shadowSmall = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let shadowMedium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let shadowLarge = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
    
    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    
    // MARK: - Spacing
    static let spacingSmall: CGFloat = 8
    static let spacingMedium: CGFloat = 16
    static let spacingLarge: CGFloat = 24
    
    // MARK: - Animation
    static let animationFast: Double = 0.2
    static let animationMedium: Double = 0.3
    static let animationSlow: Double = 0.5
    
    // MARK: - Interactive Elements
    static let buttonScale: CGFloat = 0.95
    static let cardScale: CGFloat = 0.98
    
    // MARK: - Haptic Feedback
    static let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Blur Effects
    static let blurRadius: CGFloat = 10
    
    // MARK: - Transitions
    static let slideTransition = AnyTransition.slide.combined(with: .opacity)
    static let fadeTransition = AnyTransition.opacity
    static let scaleTransition = AnyTransition.scale.combined(with: .opacity)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shadow Extension
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(
                color: AppTheme.shadowMedium.color,
                radius: AppTheme.shadowMedium.radius,
                x: AppTheme.shadowMedium.x,
                y: AppTheme.shadowMedium.y
            )
            .scaleEffect(isPressed ? AppTheme.cardScale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
                AppTheme.hapticFeedback.impactOccurred()
            }
    }
}

struct PrimaryButtonStyle: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding(.horizontal, AppTheme.spacingLarge)
            .padding(.vertical, AppTheme.spacingMedium)
            .background(AppTheme.primaryGradient)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(
                color: AppTheme.primary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isPressed ? AppTheme.buttonScale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
                AppTheme.hapticFeedback.impactOccurred()
            }
    }
}

struct GlassmorphicStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(AppTheme.cornerRadiusMedium)
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 10,
                x: 0,
                y: 5
            )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonStyle())
    }
    
    func glassmorphicStyle() -> some View {
        modifier(GlassmorphicStyle())
    }
    
    func shimmerEffect() -> some View {
        self.modifier(ShimmerEffect())
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.5),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: phase
                    )
                }
            )
            .onAppear {
                phase = 1
            }
    }
} 
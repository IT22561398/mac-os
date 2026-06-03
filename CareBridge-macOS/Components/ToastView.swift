// ToastView.swift
// NurseryConnect
// Custom toast notification with slide-in animation and auto-dismiss

import SwiftUI

enum ToastType {
    case success, error, warning, info
    
    var color: Color {
        switch self {
        case .success: return .ncSuccess
        case .error: return .ncError
        case .warning: return .ncWarning
        case .info: return .ncPrimary
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

struct ToastData: Equatable {
    let id = UUID()
    let type: ToastType
    let message: String
    
    static func == (lhs: ToastData, rhs: ToastData) -> Bool {
        lhs.id == rhs.id
    }
}

struct ToastView: View {
    let toast: ToastData
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(toast.type.color)
            
            Text(toast.message)
                .font(.ncBody(14))
                .foregroundStyle(Color.ncText)
                .lineLimit(2)
            
            Spacer(minLength: 0)
            
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isPresented = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.ncTextSecondary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.ncCard)
                .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(toast.type.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring(response: 0.3)) {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @Binding var toast: ToastData?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if let toastData = toast {
                ToastView(
                    toast: toastData,
                    isPresented: Binding(
                        get: { toast != nil },
                        set: { if !$0 { toast = nil } }
                    )
                )
                .padding(.top, 8)
                .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toast)
    }
}

extension View {
    func toast(_ toast: Binding<ToastData?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

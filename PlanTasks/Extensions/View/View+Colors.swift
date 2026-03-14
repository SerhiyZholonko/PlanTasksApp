import SwiftUI

extension Color {
    static var appTheme: AppColorTheme { Color.main }
}

extension Color {
    static var main: AppColorTheme {
        .init(
            accent: .init(.accent),
            alternateAccent: .init(.alternateAccent),
            viewBackground: .init(.viewBackground),
            cellBackground: .init(.cellBackground),
            text: .init(.text),
            secondaryText: .init(.secondaryText),
            alternateText: .init(.alternateText),
            accentContrastText: .init(.accentContrastText),
            primaryAction: .init(.primaryAction),
            neutralAction: .init(.neutralAction),
            destructive: .init(.destructive),
            success: .init(.success),
            warning: .init(.warning),
            info: .init(.info),
            error: .init(.error),
            inProgress: .init(.inProgress),
            divider: .init(.divider),
            miscellaneous: .init(.miscellaneous)
        )
    }
}

struct AppColorTheme {
    let accent: Color
    let alternateAccent: Color
    let viewBackground: Color
    let cellBackground: Color
    let text: Color
    let secondaryText: Color
    let alternateText: Color
    let accentContrastText: Color
    let primaryAction: Color
    let neutralAction: Color
    let destructive: Color
    let success: Color
    let warning: Color
    let info: Color
    let error: Color
    let inProgress: Color
    let divider: Color
    let miscellaneous: Color
}

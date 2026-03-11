import SwiftUI

// MARK: - Color Hex Extension

extension Color {
    /// 6자리 HEX 문자열(`"RRGGBB"` 또는 `"#RRGGBB"`)로 Color를 초기화한다.
    /// 잘못된 형식이거나 파싱에 실패하면 노란색 계열을 반환한다.
    init(hex: String) {
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        let scanner = Scanner(string: cleaned)
        var rgb: UInt64 = 0

        guard cleaned.count == 6, scanner.scanHexInt64(&rgb) else {
            // MemoColor.yellow(FFF176) 에 대응하는 fallback
            self.init(red: 1.0, green: 0.945, blue: 0.463)
            return
        }

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >>  8) & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - MemoColor + SwiftUI

extension MemoColor {
    /// 포스트잇 배경에 사용하는 SwiftUI `Color`
    var color: Color {
        Color(hex: rawValue)
    }
}

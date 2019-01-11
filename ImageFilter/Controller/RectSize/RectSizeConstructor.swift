import Foundation
import UIKit

final class RectSizeConstructor
{
    static func selectedAreaInCurrentDevice(for area: inout CGRect, xScale: CGFloat)
    {
        if xScale > 1 {
            area.origin.x = area.origin.x * xScale
            area.origin.y = area.origin.y * xScale
            area.size.width = area.size.width * xScale
            area.size.height = area.size.height * xScale
        }
    }
}

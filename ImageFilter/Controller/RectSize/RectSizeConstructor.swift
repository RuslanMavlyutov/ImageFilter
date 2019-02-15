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

    func transformRect(fromRect: CGRect, imageRect: CGRect) -> CGRect {
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * imageRect.width
        toRect.size.height = fromRect.size.height * imageRect.height
        toRect.origin.y = (imageRect.height) - (imageRect.height * fromRect.origin.y)
        toRect.origin.y = toRect.origin.y - toRect.size.height
        toRect.origin.x = fromRect.origin.x * imageRect.size.width
        return toRect
    }
}

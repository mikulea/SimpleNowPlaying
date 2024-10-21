import Cocoa

extension NSImage {
    func croppedToSquare() -> NSImage? {
        guard
            let cgImage = self.cgImage(
                forProposedRect: nil, context: nil, hints: nil)
        else { return nil }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        // Check if the aspect ratio is already 1:1
        if width == height {
            return self
        }

        // Calculate the square crop region (crop from the edges, keeping the center)
        let length = min(width, height)
        let xOffset = (width - length) / 2
        let yOffset = (height - length) / 2
        let cropRect = CGRect(
            x: xOffset, y: yOffset, width: length, height: length)

        // Perform the cropping
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }
        let croppedImage = NSImage(
            cgImage: croppedCGImage, size: NSSize(width: length, height: length)
        )

        return croppedImage
    }
}

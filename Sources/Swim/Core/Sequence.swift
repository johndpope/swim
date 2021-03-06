import Foundation

extension Image {
    /// Sequence of pixels.
    /// - Attention: Since the iterator has no specializations, it may be slow.
    /// Consider to use other mothods instead.
    public func pixels() -> PixelSequence<P, T> {
        return PixelSequence(image: self)
    }
}

public struct PixelSequence<P: PixelType, T: DataType>: Sequence {
    let image: Image<P, T>
    
    public func makeIterator() -> PixelIterator<P, T> {
        return PixelIterator(image: image)
    }
}

public struct PixelIterator<P: PixelType, T: DataType>: IteratorProtocol {
    let image: Image<P, T>
    
    var p = 0
    var pixel: Pixel<P, T>
    
    init(image: Image<P, T>) {
        self.image = image
        self.pixel = Pixel<P, T>(data: [T](repeating: T.swimDefaultValue, count: P.channels))
    }
    
    public mutating func next() -> Pixel<P, T>? {
        
        guard p < image.width*image.height*P.channels else {
            return nil
        }
        
        image.data.withUnsafeBufferPointer {
            let src = $0.baseAddress! + p
            pixel.data.withUnsafeMutableBufferPointer {
                let dst = $0.baseAddress!
                memcpy(dst, src, P.channels*MemoryLayout<T>.size)
            }
        }
        p += P.channels
        
        return pixel
    }
}

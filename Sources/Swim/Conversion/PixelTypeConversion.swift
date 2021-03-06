import Foundation

// MARK: - Intensity -> RGB
extension Image where P == Intensity {
    func _toRGB() -> Image<RGB, T> {
        var newImage = Image<RGB, T>(width: width, height: height)
        data.withUnsafeBufferPointer {
            var src = $0.baseAddress!
            newImage.data.withUnsafeMutableBufferPointer {
                var dst = $0.baseAddress!
                for _ in 0..<width*height {
                    dst.pointee = src.pointee
                    dst += 1
                    dst.pointee = src.pointee
                    dst += 1
                    dst.pointee = src.pointee
                    dst += 1
                    
                    src += 1
                }
            }
        }
        return newImage
    }
    
    public func toRGB() -> Image<RGB, T> {
        return _toRGB()
    }
}

// MARK: - RGB -> Intensity
extension Image where P == RGB, T: BinaryInteger {
    func _toBrightness() -> Image<Intensity, T> {
        var newImage = Image<Intensity, T>(width: width, height: height, value: 0)
        self.data.withUnsafeBufferPointer {
            var src = $0.baseAddress!
            newImage.data.withUnsafeMutableBufferPointer {
                var dst = $0.baseAddress!
                for _ in 0..<width*height {
                    dst.pointee += src.pointee
                    src += 1
                    dst.pointee += src.pointee
                    src += 1
                    dst.pointee += src.pointee
                    src += 1
                    dst.pointee /= 3
                    dst += 1
                }
            }
        }
        return newImage
    }
    
    public func toBrightness() -> Image<Intensity, T> {
        return _toBrightness()
    }
    
    func _toLuminance() -> Image<Intensity, T> {
        var newImage = Image<Intensity, T>(width: width, height: height, value: 0)
        self.data.withUnsafeBufferPointer {
            var src = $0.baseAddress!
            newImage.data.withUnsafeMutableBufferPointer {
                var dst = $0.baseAddress!
                for _ in 0..<width*height {
                    dst.pointee += 2126 * src.pointee
                    src += 1
                    dst.pointee += 7152 * src.pointee
                    src += 1
                    dst.pointee += 0722 * src.pointee
                    src += 1
                    dst.pointee /= 10000
                    dst += 1
                }
            }
        }
        return newImage
    }
    
    public func toLuminance() -> Image<Intensity, T> {
        return _toLuminance()
    }
}

extension Image where P == RGB, T == UInt8 {
    @available(*, deprecated, message: "Could cause overflow.")
    public func toBrightness() -> Image<Intensity, T> {
        return _toBrightness()
    }
    @available(*, deprecated, message: "Could cause overflow.")
    public func toLuminance() -> Image<Intensity, T> {
        return _toLuminance()
    }
}

extension Image where P == RGB, T: FloatingPoint {
    func _toBrightness() -> Image<Intensity, T> {
        var newImage = Image<Intensity, T>(width: width, height: height, value: 0)
        self.data.withUnsafeBufferPointer {
            var src = $0.baseAddress!
            newImage.data.withUnsafeMutableBufferPointer {
                var dst = $0.baseAddress!
                for _ in 0..<width*height {
                    dst.pointee += src.pointee
                    src += 1
                    dst.pointee += src.pointee
                    src += 1
                    dst.pointee += src.pointee
                    src += 1
                    dst.pointee /= 3
                    dst += 1
                }
            }
        }
        return newImage
    }
    
    public func toBrightness() -> Image<Intensity, T> {
        return _toBrightness()
    }
}

extension Image where P == RGB, T: BinaryFloatingPoint {
    func _toLuminance() -> Image<Intensity, T> {
        var newImage = Image<Intensity, T>(width: width, height: height, value: 0)
        self.data.withUnsafeBufferPointer {
            var src = $0.baseAddress!
            newImage.data.withUnsafeMutableBufferPointer {
                var dst = $0.baseAddress!
                for _ in 0..<width*height {
                    dst.pointee += 0.2126 * src.pointee
                    src += 1
                    dst.pointee += 0.7152 * src.pointee
                    src += 1
                    dst.pointee += 0.0722 * src.pointee
                    src += 1
                    dst += 1
                }
            }
        }
        return newImage
    }
    
    public func toLuminance() -> Image<Intensity, T> {
        return _toLuminance()
    }
}

// MARK: - RGB -> RGBWithAlpha
func imageFromRGB<P: RGBWithAlpha, T>(image: Image<RGB, T>, alpha: T) -> Image<P, T> {
    var newImage = Image<P, T>(width: image.width, height: image.height, value: alpha)
    image.data.withUnsafeBufferPointer {
        var src = $0.baseAddress!
        newImage.data.withUnsafeMutableBufferPointer {
            var dst = $0.baseAddress! + P.redIndex
            for _ in 0..<image.width*image.height {
                memcpy(dst, src, RGB.channels * MemoryLayout<T>.size)
                src += RGB.channels
                dst += P.channels
            }
        }
    }
    
    return newImage
}

extension Image where P: RGBWithAlpha {
    public init(image: Image<RGB, T>, alpha: T) {
        self = imageFromRGB(image: image, alpha: alpha)
    }
}

// MARK: - RGBWithAlpha -> RGB
func removeAlpha<P: RGBWithAlpha, T>(image: Image<P, T>) -> Image<RGB, T> {
    var newImage = Image<RGB, T>(width: image.width, height: image.height)
    image.data.withUnsafeBufferPointer {
        var src = $0.baseAddress! + P.redIndex
        newImage.data.withUnsafeMutableBufferPointer {
            var dst = $0.baseAddress!
            for _ in 0..<image.width*image.height {
                memcpy(dst, src, RGB.channels * MemoryLayout<T>.size)
                dst += RGB.channels
                src += P.channels
            }
        }
    }
    return newImage
}

extension Image where P: RGBWithAlpha {
    public func toRGB() -> Image<RGB, T> {
        return removeAlpha(image: self)
    }
}

extension Image where P == RGB {
    public init<P: RGBWithAlpha>(image: Image<P, T>) {
        self = removeAlpha(image: image)
    }
}

// MARK: - RGBA <-> ARGB

func permuteChannels<T>(data: [T], permutation: [Int]) -> [T] {
    assert(Set(permutation) == Set(0..<permutation.count))
    var ret = data
    let numChannels = permutation.count
    
    data.withUnsafeBufferPointer {
        var src = $0.baseAddress!
        ret.withUnsafeMutableBufferPointer {
            var dst = $0.baseAddress!
            
            for _ in 0..<data.count/permutation.count {
                for c in 0..<numChannels {
                    dst[c] = src[permutation[c]]
                }
                src += numChannels
                dst += numChannels
            }
        }
    }
    
    return ret
}

extension Image where P == RGBA {
    public func toARGB() -> Image<ARGB, T> {
        let data = permuteChannels(data: self.data, permutation: [3, 0, 1, 2])
        return Image<ARGB, T>(width: width, height: height, argb: data)
    }
}

extension Image where P == ARGB {
    public func toRGBA() -> Image<RGBA, T> {
        let data = permuteChannels(data: self.data, permutation: [1, 2, 3, 0])
        return Image<RGBA, T>(width: width, height: height, rgba: data)
    }
}


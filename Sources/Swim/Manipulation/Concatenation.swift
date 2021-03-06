extension Image {
    static func _concatH<P, T>(_ images: [Image<P, T>]) -> Image<P, T> {
        let width: Int = images.map { $0.width }.reduce(0, +)
        let height: Int = images[0].height
        precondition(images.all { $0.height == height }, "All images must have same `height`.")
        
        var image = Image<P, T>(width: width, height: height)
        
        var start = 0
        for im in images {
            let cols: CountableRange<Int> = start..<start+im.width
            image[cols: cols] = im
            start += im.width
        }
        
        return image
    }
    
    public static func concatH<P, T>(_ images: [Image<P, T>]) -> Image<P, T> {
        return _concatH(images)
    }
}

extension Image {
    static func _concatV<P, T>(_ images: [Image<P, T>]) -> Image<P, T> {
        let width: Int = images[0].width
        let height: Int = images.map { $0.height }.reduce(0, +)
        
        precondition(images.all { $0.width == width }, "All images must have same `width`.")
        
        var image = Image<P, T>(width: width, height: height)
        
        var start = 0
        for im in images {
            let rows = start..<start+im.height
            image[rows: rows] = im
            start += im.height
        }
        
        return image
    }
    
    public static func concatV<P, T>(_ images: [Image<P, T>]) -> Image<P, T> {
        return _concatV(images)
    }
}



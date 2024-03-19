internal struct Units {
    
    // MARK: - properties
    internal let bytes: Int64
    
    internal var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    internal var megabytes: Double {
        return kilobytes / 1_024
    }
    
    internal var gigabytes: Double {
        return megabytes / 1_024
    }
    
    // MARK: - init
    internal init(bytes: Int64) {
        self.bytes = bytes
    }
    
    // MARK: - function
    internal func getReadableUnit() -> String {
        switch bytes {
        case 0..<1_024:
            return "\(bytes) Bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) MB"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) GB"
        default:
            return "\(bytes) Bytes"
        }
    }
    
}

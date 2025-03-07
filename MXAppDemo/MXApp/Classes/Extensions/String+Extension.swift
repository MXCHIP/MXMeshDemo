
import Foundation
import CommonCrypto

extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
    
    var sha256: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}

func md5File(url: URL) -> String? {
        
    let bufferSize = 1024 * 1024
    
    do {
        
        let file = try FileHandle(forReadingFrom: url)
        defer {
            file.closeFile()
        }
        
        
        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        
        while case let data = file.readData(ofLength: bufferSize), data.count > 0 {
            data.withUnsafeBytes {
                _ = CC_MD5_Update(&context, $0, CC_LONG(data.count))
            }
        }
        
        
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        digest.withUnsafeMutableBytes {
            _ = CC_MD5_Final($0, &context)
        }
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
        
    } catch {
        print("Cannot open file:", error.localizedDescription)
        return nil
    }
}

extension String {
    
    func nsRange(of string: String) -> NSRange? {
        guard let range = self.range(of: string) else { return nil }
        
        let startPos = self.distance(from: self.startIndex, to: range.lowerBound)
        let endPos = self.distance(from: self.startIndex, to: range.upperBound)
        return NSMakeRange(startPos, endPos - startPos)
     }
    
    func mxSubString(with range: Range<Int>) -> String {
        let lower = range.lowerBound
        let upper = range.upperBound
        
        if upper >= self.count {
            return self
        }
        
        let start = self.index(self.startIndex, offsetBy: lower)
        let end = self.index(self.startIndex, offsetBy: upper)
        let range = start...end
        
        let sub = String(self[range])
        
        return sub
    }
    
    func mxSubString(with range: ClosedRange<Int>) -> String {
        let lower = range.lowerBound
        let upper = range.upperBound
        
        if upper >= self.count {
            return self
        }
        
        let start = self.index(self.startIndex, offsetBy: lower)
        let end = self.index(self.startIndex, offsetBy: upper)
        let range = start...end
        
        let sub = String(self[range])
        
        return sub
    }
    
}


extension String {
    
    func phoneNumberEncryption() -> String {
        
        var phoneNumber: String!
        
        var end = 7
        if self.count < 7 {
            end = self.count
        }
        let range = self.index(self.startIndex, offsetBy: 3)..<self.index(self.startIndex, offsetBy: end)
        
        var encryption = ""
        var length = 4
        if self.count < 7 {
            length = self.count - 3
        }
        for _ in 0..<length {
            encryption.append(contentsOf: "*")
        }
        
        phoneNumber = self.replacingCharacters(in: range, with: encryption)
        
        return phoneNumber
    }
    
}

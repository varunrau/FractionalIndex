
let base = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
let smallestInteger = "A00000000000000000000000000"
let firstInteger = "a0"

import Foundation

fileprivate extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
    
    subscript(safe idx: Int) -> String? {
        if count > idx {
            let i = index(startIndex, offsetBy: idx)
            return String(self[i])
        }
        return nil
    }
    
    func unicodeAt(index: Int) -> UInt32 {
        let scalars = (self[safe: index] ?? "").unicodeScalars
        if scalars.count > 0 {
            return scalars[scalars.startIndex].value
        }
        return 0
    }
    
    func getSuffix(_ offsetBy: Int) -> String {
        if count < offsetBy {
            return ""
        }
        return String(suffix(from: index(startIndex, offsetBy: offsetBy)))
    }
}

fileprivate extension Collection {
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
}

enum FractionalIndexError: Error {
    case wrongOrder(String)
    case trailingZero
    case invalidOrderKey(String)
    case invalidKeyRanage(String, String)
    case keyspaceExhausted
}

/**
 a: order key or an empty string
 b: order key greater than a, or null

  returns an order key such that a < return < c
 */
func getMidpoint(a: String, b: String?) throws -> String {
    print("a: \(a), b: \(b ?? "nil")")
    if let b = b, a >= b {
        throw FractionalIndexError.wrongOrder("\(a) >= \(b)")
    }
    if let b = b, b.last == "0" && a.last == "0" {
        throw FractionalIndexError.trailingZero
    }
    if let b = b {
        var n = 0
        while a[safe: n] ?? "0" == b[safe: n] {
            n += 1
        }
        if n > 0 {
            let commonPrefix = String(b.prefix(n))
            return "\(commonPrefix)\(try getMidpoint(a: a.getSuffix(n), b: b.getSuffix(n)))"
        }
    }
    let digitA = a.first != nil ? base.distance(from: base.startIndex, to: base.firstIndex(of: a.first!) ?? base.endIndex) : 0
    let digitB = b?.first != nil ? base.distance(from: base.startIndex, to: base.firstIndex(of: b!.first!) ?? base.endIndex) : base.count
    
    if digitB - digitA > 1 {
        let midDigit = Int(round(0.5 * Double(digitA + digitB)))
        return String(base[base.index(base.startIndex, offsetBy: midDigit)])
    } else {
        if b?.count ?? 0 > 1 {
            return String((b?.first!)!)
        } else {
            let head = String(base[base.index(base.startIndex, offsetBy: digitA)])
            let aTail = a.count > 0 ? String(a.suffix(from: a.index(after: a.startIndex))) : ""
            let tail = try getMidpoint(a: aTail, b: nil)
            return "\(head)\(tail)"
        }
    }
}

func getIntegerLength(head: UnicodeScalar) throws -> Int {
    if head >= "a" && head <= "z" {
        return Int(head.value) - Int(UnicodeScalar("a").value) + 2
    } else if head >= "A" && head <= "Z" {
        return Int(UnicodeScalar("Z").value) - Int(head.value) + 2
    } else {
        throw FractionalIndexError.invalidOrderKey(String(head))
    }
}

func validateInteger(str: String) throws {
    if let head = str.unicodeScalars.first {
        let length = try getIntegerLength(head: head)
        if str.count != length {
            throw FractionalIndexError.invalidOrderKey(str)
        }
    }
}

func incrementInteger(x: String) throws -> String? {
    try validateInteger(str: x)
    let head = x.first!
    var digs = Array(x.suffix(from: x.index(after: x.startIndex)))
    var carry = true
    var i = digs.count - 1
    while i >= 0 && carry {
        let d = base.distance(
            from: base.startIndex,
            to: base.firstIndex(of: digs[i])!
        ) + 1
        if d == base.count {
            digs[i] = "0"
        } else {
            digs[i] = base[base.index(base.startIndex, offsetBy: d)]
            carry = false
        }
        i -= 1
    }
    if carry {
        if head == "Z" {
            return "a0"
        }
        if head == "z" {
            return nil
        }
        let h = String(UnicodeScalar(String(head).unicodeAt(index: 0) + 1)!)
        if h > "a" {
            digs.append("0")
        } else {
            _ = digs.popLast()
        }
        return h + digs.map { String($0) }.joined()
    } else {
        return String(head) + digs.map { String($0) }.joined()
    }
}

func decrementInteger(x: String) throws -> String? {
    try validateInteger(str: x)
    let head = x.first!
    var digs = Array(x.suffix(from: x.index(after: x.startIndex)))
    var borrow = true
    var i = digs.count - 1
    while i >= 0 && borrow {
        let d = base.distance(
            from: base.startIndex,
            to: base.firstIndex(of: digs[i])!
        ) - 1
        if d == -1 {
            digs[i] = base.last!
        } else {
            digs[i] = base[base.index(base.startIndex, offsetBy: d)]
            borrow = false
        }
        i -= 1
    }
    if borrow {
        if head == "a" {
            return "Z" + String(base.last!)
        }
        if head == "A" {
            return nil
        }
        let h = String(UnicodeScalar(String(head).unicodeAt(index: 0) - 1)!)
        if h < "Z" {
            digs.append(base.last!)
        } else {
            _ = digs.popLast()
        }
        return h + digs.map { String($0) }.joined()
    } else {
        return String(head) + digs.map { String($0) }.joined()
    }
}

func getIntegerPart(key: String) throws -> String {
    if let head = key.unicodeScalars.first {
        let keyLength = try getIntegerLength(head: head)
        if keyLength > key.count {
            throw FractionalIndexError.invalidOrderKey(key)
        }
        return String(key[0..<keyLength])
    }
    throw FractionalIndexError.invalidOrderKey(key)
}

func validateOrderKey(key: String) throws {
    if key == smallestInteger {
        throw FractionalIndexError.invalidOrderKey(key)
    }
    let integer = try getIntegerPart(key: key)
    let f = key.getSuffix(integer.count)
    if f.last == "0" {
        throw FractionalIndexError.invalidOrderKey(key)
    }
}

func generateKeyBetween(a: String?, b: String?) throws -> String {
    if let a = a {
        try validateOrderKey(key: a)
    }
    if let b = b {
        try validateOrderKey(key: b)
    }
    if let a = a, let b = b, a >= b {
        throw FractionalIndexError.invalidKeyRanage(a, b)
    }
    if let a = a, let b = b {
        let ia = try getIntegerPart(key: a)
        let fa = a.getSuffix(ia.count)
        let ib = try getIntegerPart(key: b)
        let fb = b.getSuffix(ib.count)
        if ia == ib {
            let midpoint = try getMidpoint(a: fa, b: fb)
            return ia + midpoint
        }
        if let i = try incrementInteger(x: ia) {
            let midpoint = try getMidpoint(a: fa, b: nil)
            return i < b ? i : ia + midpoint
        } else {
            throw FractionalIndexError.keyspaceExhausted
        }
    } else if let b = b {
        let ib = try getIntegerPart(key: b)
        let fb = b.getSuffix(ib.count)
        if ib == firstInteger {
            let midpoint = try getMidpoint(a: "", b: fb)
            return ib + midpoint
        }
        if let dec = try decrementInteger(x: ib) {
            return ib < b ? ib : dec
        } else {
            throw FractionalIndexError.keyspaceExhausted
        }
    } else if let a = a {
        let ia = try getIntegerPart(key: a)
        let fa = a.getSuffix(ia.count)
        if let inc = try incrementInteger(x: ia) {
            return inc
        } else {
            let midpoint = try getMidpoint(a: fa, b: nil)
            return ia + midpoint
        }
    } else {
        return firstInteger
    }
}

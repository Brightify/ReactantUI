// MIT License
//
// Copyright (c) 2017 Ivo Stratev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// https://github.com/NoHomey/swift-array-variations/blob/master/Sources/swift_array_variations.swift

import Foundation

internal func strike(_ array: [Int], from: [Int]) -> [Int] {
    var result: Array<Int> = []

    for element in from {
        if array.firstIndex(of: element) == nil {
            result.append(element)
        }
    }

    return result
}

extension Array where Element: Equatable {
    func variations(class count: Int) -> [[Element]] {
        let length = ((self.count - count + 1)...self.count).reduce(1, { a, b in a * b })
        let indexes = Array<Int>(0..<self.count)
        var repeats = Array<Int>(repeating: length / self.count, count: count)
        var divisor = self.count
        for i in 1..<count {
            divisor -= 1
            repeats[i] = repeats[i - 1] / divisor
        }
        var result = Array<Array<Int>>(repeating: [], count: length)
        var k = 0
        for i in 0..<count {
            k = 0
            while k < length {
                for number in strike(result[k], from: indexes) {
                    for _ in 0..<repeats[i] {
                        result[k].append(number)
                        k += 1
                    }
                }
            }
        }

        return result.map { variation in variation.map { element in self[element] } }
    }
}

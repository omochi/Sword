import Foundation

extension Date {

  var milliseconds: Int {
    return Int((self.timeIntervalSince1970 * 1000.0).rounded())
  }

}

extension String {

  var date: Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

    return dateFormat.date(from: self)!
  }

}

extension Data {

  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }

}
import Foundation
import Testing

import HTTPSignature

struct DateTests {
	@Test
	func leadingZerosAnd24h() throws {
		let date = Date(timeIntervalSince1970: 1762183551)
		let dateValue = DateFormatter.httpDateFormatter.string(from: date)

		#expect("Mon, 03 Nov 2025 15:25:51 GMT" == dateValue)
	}
}

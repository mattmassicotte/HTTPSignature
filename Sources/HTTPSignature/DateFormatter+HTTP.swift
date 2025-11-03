import Foundation

extension DateFormatter {
	public static var httpDateFormatter: DateFormatter {
		let dateFormatter = DateFormatter()

		// all with leading zeros
		// <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
		dateFormatter.timeZone = TimeZone.gmt
		dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss 'GMT'"

		return dateFormatter
	}
}

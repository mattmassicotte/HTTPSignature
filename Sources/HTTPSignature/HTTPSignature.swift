import Foundation

public enum Algorithm: String, Codable, Hashable, Sendable {
	case HS256 = "hmac-sha256"
	case RS256 = "rsa-sha256"
	case RS512 = "rsa-pss-sha512"
	case ES256 = "ecdsa-p256-sha256"
	case ES384 = "ecdsa-p384-sha384"
	case ED25519 = "ed25519"

	public struct Provider {
		public let signer: (Algorithm, Data) throws -> Data
		public let hasher: (Algorithm, Data) -> Data

		public init(
			signer: @escaping (Algorithm, Data) throws -> Data,
			hasher: @escaping (Algorithm, Data) -> Data
		) {
			self.signer = signer
			self.hasher = hasher
		}
	}

	public var digestName: String {
		switch self {
		case .HS256, .ES256, .RS256, .ED25519:
			"SHA-256"
		case .RS512:
			"SHA-512"
		case .ES384:
			"SHA-384"
		}
	}
}

public struct SignedPayload {
	public let algorithm: Algorithm
	public let digest: String
	public let signatureHeaderValue: String

	public init(digest: String, signatureHeaderValue: String, algorithm: Algorithm) {
		self.digest = digest
		self.signatureHeaderValue = signatureHeaderValue
		self.algorithm = algorithm
	}

	public var digestHeaderValue: String {
		"\(algorithm.digestName)=\(digest)"
	}
}

public struct HTTPSignatureParameters {
	public typealias Header = (String, String)

	public var path: String
	public var method: String
	public var keyId: String
	public var algorithm: Algorithm
	public var headers: [Header]
	public var body: Data

	public init(
		path: String,
		method: String,
		keyId: String,
		algorithm: Algorithm,
		headers: [Header],
		body: Data
	) {
		self.path = path
		self.method = method
		self.keyId = keyId
		self.algorithm = algorithm
		self.headers = headers
		self.body = body
	}

	func message(digest: String) -> String {
		let digestPair = ("digest", digest)

		let headerString = (headers + [digestPair])
			.map { "\($0.lowercased()): \($1)" }
			.joined(separator: "\n")

		return "(request-target): \(method.lowercased()) \(path)\n"
			.appending(headerString)
	}

	public func sign(with provider: Algorithm.Provider) throws -> SignedPayload {
		let digest = provider.hasher(algorithm, body).base64EncodedString()
		let digestHeader = "\(algorithm.digestName)=\(digest)"

		let message = message(digest: digestHeader)

		let effectiveHeaders = (headers + [("digest", digest)])

		let signature = try provider.signer(algorithm, Data(message.utf8)).base64EncodedString()
		let headerNames = ["(request-target)"] + effectiveHeaders.map { $0.0.lowercased() }
		let headersValue = headerNames.joined(separator: " ")

		let signatureHeaderValue = [
			("keyId", keyId),
			("algorithm", algorithm.rawValue),
			("headers", headersValue),
			("signature", signature)
		]
			.map { "\($0)=\"\($1)\""}
			.joined(separator: ",")

		return SignedPayload(
			digest: digest,
			signatureHeaderValue: signatureHeaderValue,
			algorithm: algorithm
		)
	}
}


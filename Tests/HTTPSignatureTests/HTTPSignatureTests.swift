import Foundation
import Testing

import HTTPSignature

struct HTTPSignatureTests {
	@Test
	func minimalSignature() throws {
		let bodyData = Data("Corlieus".utf8)
		let params = HTTPSignatureParameters(
			path: "/hello",
			method: "GET",
			keyId: "mah-key",
			algorithm: .RS256,
			headers: [("host", "server.com")],
			body: bodyData
		)

		let message = """
 (request-target): get /hello
 host: server.com
 digest: SHA-256=UEhPTllfRElHRVNU
 """

		let provider = Algorithm.Provider { algo, data in
			try #require(algo == .RS256)
			#expect(String(decoding: data, as: UTF8.self) == message)

			return Data("PHONY_SIGNATURE".utf8)
		} hasher: { algo, data in
			precondition(algo == .RS256)
			#expect(data == bodyData)

			return Data("PHONY_DIGEST".utf8)
		}

		let output = try params.sign(with: provider)

		#expect(output.digest == Data("PHONY_DIGEST".utf8).base64EncodedString())

		let encodedSig = Data("PHONY_SIGNATURE".utf8).base64EncodedString()
		let headerValue = """
 keyId="mah-key",algorithm="rsa-sha256",headers="(request-target) host digest",signature="\(encodedSig)"
 """
		#expect(output.signatureHeaderValue == headerValue)
	}

	@Test
	func headerOrderAndCase() throws {
		let bodyData = Data("Vito".utf8)
		let params = HTTPSignatureParameters(
			path: "/hello",
			method: "GET",
			keyId: "mah-key",
			algorithm: .RS256,
			headers: [("a", "1"), ("host", "server.com"), ("B", "2"), ("C", "3")],
			body: bodyData
		)

		let message = """
(request-target): get /hello
a: 1
host: server.com
b: 2
c: 3
digest: SHA-256=UEhPTllfRElHRVNU
"""

		let provider = Algorithm.Provider { algo, data in
			try #require(algo == .RS256)
			#expect(String(decoding: data, as: UTF8.self) == message)

			return Data("PHONY_SIGNATURE".utf8)
		} hasher: { algo, data in
			precondition(algo == .RS256)
			#expect(data == bodyData)

			return Data("PHONY_DIGEST".utf8)
		}

		let output = try params.sign(with: provider)

		#expect(output.digest == Data("PHONY_DIGEST".utf8).base64EncodedString())

		let encodedSig = Data("PHONY_SIGNATURE".utf8).base64EncodedString()
		let headerValue = """
keyId="mah-key",algorithm="rsa-sha256",headers="(request-target) a host b c digest",signature="\(encodedSig)"
"""
		#expect(output.signatureHeaderValue == headerValue)
		#expect(output.digestHeaderValue == "SHA-256=UEhPTllfRElHRVNU")
	}
}

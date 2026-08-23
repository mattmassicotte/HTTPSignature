
<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

</div>

# HTTPSignature
An HTTP Message Signatures library for Swift.

This is an implementation of the [RFC 941](https://datatracker.ietf.org/doc/html/rfc9421) specification. It does not include the needed cryptographic functions. But, you use your own as needed. I think it should be possible to build in direct support for CryptoKit on Apple platforms as well.

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/mattmassicotte/HTTPSignature", branch: "main")
]
```

## Usage

```swift
import HTTPSignature

// prepare the API-agnostic request content that needs a signature
let bodyData = Data("Corlieus".utf8)
let params = HTTPSignatureParameters(
	path: "/hello",
	method: "GET",
	keyId: "mah-key",
	algorithm: .RS256,
	headers: [("host", "server.com")],
	body: bodyData
)

let provider = Algorithm.Provider { algo, data in
	// custom cryptographic signature here
} hasher: { algo, data in
	// custom cryptographic hashing code here
}
```

Here's what an implementation looks like that uses [swift-crypto](https://github.com/apple/swift-crypto) for RS256.

```swift
let provider = Algorithm.Provider(
	signer: { algo, data in
		precondition(algo == .RS256)

		let privateKey = try _RSA.Signing.PrivateKey(pemRepresentation: actorPrivateKey)

		let sig = try privateKey.signature(
			for: data
		)

		return sig.rawRepresentation
	},
	hasher: { algo, data in
		precondition(algo == .RS256)

		let digest = SHA256.hash(data: data)

		return Data(digest)
	}
)
```

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I use indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/mattmassicotte/HTTPSignature/actions
[build status badge]: https://github.com/mattmassicotte/HTTPSignature/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/mattmassicotte/HTTPSignature
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmattmassicotte%2FHTTPSignature%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/mattmassicotte/HTTPSignature/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue

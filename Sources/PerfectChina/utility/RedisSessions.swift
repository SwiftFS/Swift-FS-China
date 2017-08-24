//
//  RedisSessions.swift
//  PerfectSessionRedis
//
//  Created by Jonathan Guthrie on 2017-03-05.
//
//

//import TurnstileCrypto
import PerfectRedis
import PerfectSession
import PerfectHTTP
import Foundation
import PerfectThread

public struct RedisSessionConnector {

	public static var host: String		= "127.0.0.1"
	public static var password: String	= ""
	public static var port: Int			= redisDefaultPort

	private init(){}

	public static func connect() -> RedisClientIdentifier {
		return RedisClientIdentifier(withHost: host, port: port, password: password)
	}
}


public struct RedisSessions {


	public func save(session: PerfectSession) {
		var s = session
		s.updated = Int(Date().timeIntervalSince1970)
		let encoded = s.tojson().replacingOccurrences(of: "\"", with: "\\\"")
		RedisClient.getClient(withIdentifier: RedisSessionConnector.connect()) {
			c in
			do {	
				let client = try c()
				client.set(key: s.token, value: .string(encoded), expires: Double(SessionConfig.idle)) {
					response in
					defer {
						RedisClient.releaseClient(client)
					}
				}
			} catch {
				print(error)
			}
		}

	}

	public func start(_ request: HTTPRequest) -> PerfectSession {
//		let rand = URandom()
		var session = PerfectSession()
//		session.token = rand.secureToken
		session.token = UUID().uuidString
		session.data["userid"]		= session.userid
		session.data["created"]		= session.created
		session.data["updated"]		= session.updated
		session.data["idle"]		= SessionConfig.idle
		session.data["ipaddress"]	= request.remoteAddress.host
		session.data["useragent"]	= request.header(.userAgent) ?? "unknown"
		session.setCSRF()

		do {
			var encoded = try session.data.jsonEncodedString()
			encoded = encoded.replacingOccurrences(of: "\"", with: "\\\"")
			RedisClient.getClient(withIdentifier: RedisSessionConnector.connect()) {
				c in
				do {
					let client = try c()
					client.set(key: session.token, value: .string(encoded), expires: Double(SessionConfig.idle)) {
						response in
						defer {
							RedisClient.releaseClient(client)
						}
						guard response.isSimpleOK else {
							print("Unexpected response \(response)")
							return
						}
					}
				} catch {
					print(error)
				}
			}
		} catch {
			print(error)
		}
		return session
	}

	/// Deletes the session for a session identifier.
	public func destroy(_ request: HTTPRequest, _ response: HTTPResponse) {
		if let t = request.session?.token {
			RedisClient.getClient(withIdentifier: RedisSessionConnector.connect()) {
				c in
				do {
					let client = try c()
					client.delete(keys: t) {
						response in
						defer {
							RedisClient.releaseClient(client)
						}
					}
				} catch {
					print(error)
				}
			}
		}

		// Reset cookie to make absolutely sure it does not get recreated in some circumstances.
		var domain = ""
		if !SessionConfig.cookieDomain.isEmpty {
			domain = SessionConfig.cookieDomain
		}
		response.addCookie(HTTPCookie(
			name: SessionConfig.name,
			value: "",
			domain: domain,
			expires: .relativeSeconds(SessionConfig.idle),
			path: SessionConfig.cookiePath,
			secure: SessionConfig.cookieSecure,
			httpOnly: SessionConfig.cookieHTTPOnly,
			sameSite: SessionConfig.cookieSameSite
			)
		)

	}

	public func resume(token: String) -> PerfectSession {
		let p = Promise<PerfectSession> {
			p in
            
			RedisClient.getClient(withIdentifier: RedisSessionConnector.connect()) {
				c in
				do {
					let client = try c()
					client.get(key: token) {
						response in
						defer {
							RedisClient.releaseClient(client)
						}
						var session = PerfectSession()
						guard case .bulkString = response else {
							print("Unexpected response \(response)")
							p.set(session)
							return
						}

						guard let data = response.toString(), !data.isEmpty else {
							print("NO DATA")
							p.set(session)
							return
						}
						do {
							let opts = try data.jsonDecode() as! [String: Any]
							session.token = token
							session.userid = opts["userid"] as? String ?? ""
							session.created = opts["created"] as? Int ?? 0
							session.updated = opts["updated"] as? Int ?? 0
							session.idle = opts["idle"] as? Int ?? 0
							session.ipaddress = opts["ipaddress"] as? String ?? ""
							session.useragent = opts["useragent"] as? String ?? ""
							session.data = opts

							session._state = "resume"
							p.set(session)
						} catch {
							print("Unexpected json response \(error)")
							p.fail(error)
						}
					}
				} catch {
					p.fail(error)
				}
			}
		}
		do {
			let session = try p.wait(seconds: 50.0)
			return session!
		} catch {
			return PerfectSession()
		}
	}



	func isError(_ errorMsg: String) -> Bool {
		if errorMsg.contains(string: "ERROR") {
			print(errorMsg)
			return true
		}
		return false
	}
	
}




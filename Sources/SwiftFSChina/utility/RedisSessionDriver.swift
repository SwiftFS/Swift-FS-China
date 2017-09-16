//
//  RedisSessionDriver.swift
//  PerfectSessionRedis
//
//  Created by Jonathan Guthrie on 2017-03-05.
//
//

import PerfectHTTP
import PerfectSession
import PerfectLogger

public struct SessionRedisDriver {
	public var requestFilter: (HTTPRequestFilter, HTTPFilterPriority)
	public var responseFilter: (HTTPResponseFilter, HTTPFilterPriority)


	public init() {
		let filter = SessionRedisFilter()
		requestFilter = (filter, HTTPFilterPriority.high)
		responseFilter = (filter, HTTPFilterPriority.high)
	}
}
public class SessionRedisFilter {
	var driver = RedisSessions()
}

extension SessionRedisFilter: HTTPRequestFilter {

	public func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
		if request.path != SessionConfig.healthCheckRoute {
			var createSession = true
			var session = PerfectSession()

			if let token = request.getCookie(name: SessionConfig.name) {
				// From Cookie
				session = driver.resume(token: token)
			} else if let bearer = request.header(.authorization), !bearer.isEmpty {
				// From Bearer Token
				let b = bearer.chompLeft("Bearer ")
				session = driver.resume(token: b)

			} else if let s = request.param(name: "session"), !s.isEmpty {
				// From Session Link
				session = driver.resume(token: s)
			}

			if !session.token.isEmpty {
				//				var session = driver.resume(token: token)
				if session.isValid(request) {
					session._state = "resume"
					request.session = session
					createSession = false
				} else {
					driver.destroy(request, response)
				}
			}
			if createSession {
				//start new session
				request.session = driver.start(request)
			}

			// Now process CSRF
			if request.session?._state != "new" || request.method == .post {
				//print("Check CSRF Request: \(CSRFFilter.filter(request))")
				if !CSRFFilter.filter(request) {

					switch SessionConfig.CSRF.failAction {
					case .fail:
						response.status = .notAcceptable
						callback(.halt(request, response))
						return
					case .log:
						LogFile.info("CSRF FAIL")

					default:
						print("CSRF FAIL (console notification only)")
					}
				}
			}

			CORSheaders.make(request, response)
		}
		callback(HTTPRequestFilterResult.continue(request, response))
	}

	/// Wrapper enabling PerfectHTTP 2.1 filter support
	public static func filterAPIRequest(data: [String:Any]) throws -> HTTPRequestFilter {
		return SessionRedisFilter()
	}

}

extension SessionRedisFilter: HTTPResponseFilter {

	/// Called once before headers are sent to the client.
	public func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {

		guard let session = response.request.session else {
			return callback(.continue)
		}

		driver.save(session: session)
		let sessionID = session.token

		// 0.0.6 updates
		var domain = ""
		if !SessionConfig.cookieDomain.isEmpty {
			domain = SessionConfig.cookieDomain
		}

		if !sessionID.isEmpty {
			if response.header(.contentType) == "application/json" {
				response.addHeader(.custom(name: "Authorization"), value: sessionID)
				if let t = session.data["csrf"] {
					response.addHeader(.custom(name: "CSRF-TOKEN"), value: t as! String)
				}
			} else {

				response.addCookie(HTTPCookie(
					name: SessionConfig.name,
					value: "\(sessionID)",
					domain: domain,
					expires: .relativeSeconds(SessionConfig.idle),
					path: SessionConfig.cookiePath,
					secure: SessionConfig.cookieSecure,
					httpOnly: SessionConfig.cookieHTTPOnly,
					sameSite: SessionConfig.cookieSameSite
					)
				)
				// CSRF Set Cookie
				if SessionConfig.CSRF.checkState {
					//print("in SessionConfig.CSRFCheckState")
					CSRFFilter.setCookie(response)
				}
			}
		}
		callback(.continue)
	}

	/// Wrapper enabling PerfectHTTP 2.1 filter support
	public static func filterAPIResponse(data: [String:Any]) throws -> HTTPResponseFilter {
		return SessionRedisFilter()
	}


	/// Called zero or more times for each bit of body data which is sent to the client.
	public func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
		callback(.continue)
	}
}

//
//  Errors.swift
//  Perfect-App-Template
//
//  Created by Jonathan Guthrie on 2017-04-14.
//
//

public enum ErrorCode: Error {

	/// The request was invalid
	case invalidRequest,

	/// The client is not authorized to make this request
	unauthorizedClient,

	/// The user or server denied this request
	accessDenied,

	/// The server does not support an authorization code using this method
	unsupportedResponseType,

	/// An internal server error occurred
	serverError,

	/// The server is busy
	temporarilyUnavailable,

	/// The method is unimplemented
	unimplemented
}

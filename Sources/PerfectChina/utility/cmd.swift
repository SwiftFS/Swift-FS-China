////
////  cmd.swift
////  Perfect-App-Template
////
////  Created by Jonathan Guthrie on 2017-04-10.
////
////
//
//
//import PerfectLib
//import Foundation
//
//#if os(Linux)
//	import SwiftGlibc
//#else
//	import Darwin
//#endif
//
//
//extension File {
//	func switchToNonBlocking() {
//		guard self.isOpen else {
//			return
//		}
//		let fd = Int32(self.fd)
//		let flags = fcntl(fd, F_GETFL)
//		guard flags >= 0 else {
//			return
//		}
//		let _ = fcntl(fd, F_SETFL, flags | O_NONBLOCK)
//		var one = Int32(1)
//		setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &one, UInt32(MemoryLayout<Int32>.size))
//		setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, UInt32(MemoryLayout<Int32>.size));
//	}
//}
//
//private var pathFromShell: String {
//	do {
//		let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/bash"
//		//		print("Using shell: \(shell)")
//		let env = [("HOME", ProcessInfo.processInfo.environment["HOME"]!), ("LANG", "en_CA.UTF-8")]
//		let proc: SysProcess
//		switch shell.lastFilePathComponent {
//		case "zsh":
//			proc = try SysProcess(shell, args: ["-ci", "echo $PATH"], env: env)
//		default:
//			proc = try SysProcess(shell, args: ["-cl", "echo $PATH"], env: env)
//		}
//		var read = ""
//		while true {
//			do {
//				guard let s = try proc.stdout?.readSomeBytes(count: 1024) , s.count > 0 else {
//					break
//				}
//				let str = UTF8Encoding.encode(bytes: s)
//				read += str
//			} catch PerfectLib.PerfectError.fileError(let code, _) {
//				if code != EINTR {
//					break
//				}
//			}
//		}
//
//		//		print("Read PATH: \(read)")
//
//		let res = try proc.wait(hang: true)
//		if res == 0 && !read.isEmpty {
//			return read
//		}
//	} catch {
//		print("Error thrown while echoing $PATH: \(error)")
//	}
//	//	print("Returning fallback path")
//	return "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local:/usr/local/Cellar:~/.swiftenv/"
//}
//
//func sleep(seconds: Double) {
//	guard seconds >= 0.0 else {
//		return
//	}
//	let milliseconds = Int(seconds * 1000.0)
//	var tv = timeval()
//	tv.tv_sec = milliseconds/1000
//	tv.tv_usec = Int32((milliseconds%1000)*1000)
//	select(0, nil, nil, nil, &tv)
//}
//
//func runProc(_ cmd: String, args: [String], envs: [String:String] = [:], quoteArgs: Bool = true, read: ((String) -> ())? = nil) throws {
//	var ienvs = [("PATH", pathFromShell),
//	             ("HOME", ProcessInfo.processInfo.environment["HOME"]!),
//	             ("LANG", "en_CA.UTF-8")]
//	for e in envs {
//		ienvs.append(e)
//	}
//	let cmdPath = File(cmd).path
//	var newCmd = "'\(cmdPath)\'"
//	for n in 1...args.count {
//		if quoteArgs {
//			newCmd.append(" \"${\(n)}\"")
//		} else {
//			newCmd.append(" ${\(n)}")
//		}
//	}
//	let shell = "/bin/sh"
//	let proc = try SysProcess(shell, args: ["--login", "-ci", newCmd, cmdPath] + args, env: ienvs)
//
//	if let read = read {
//		while true {
//			do {
//				guard let s = try proc.stdout?.readSomeBytes(count: 1024) , s.count > 0 else {
//					break
//				}
//				let str = UTF8Encoding.encode(bytes: s)
//				read(str)
//			} catch PerfectLib.PerfectError.fileError(let code, _) {
//				if code != EINTR {
//					break
//				}
//			}
//		}
//	}
//	let res = try proc.wait(hang: true)
//	if res != 0 {
//		let s = try proc.stderr?.readString()
//		throw PerfectError.systemError(Int32(res), s!)
//	}
//}
//
//func runProc(_ cmd: String, args: [String], envs: [String:String], quoteArgs: Bool, readStdin: ((String) -> ()), readStderr: ((String) -> ())) throws -> Int {
//	var ienvs = [("PATH", pathFromShell),
//	             ("HOME", ProcessInfo.processInfo.environment["HOME"]!),
//	             ("LANG", "en_CA.UTF-8")]
//	for e in envs {
//		ienvs.append(e)
//	}
//	let cmdPath = File(cmd).path
//	var newCmd = "'\(cmdPath)\'"
//	for n in 1...args.count {
//		if quoteArgs {
//			newCmd.append(" \"${\(n)}\"")
//		} else {
//			newCmd.append(" ${\(n)}")
//		}
//	}
//	let shell = "/bin/sh"
//	let proc = try SysProcess(shell, args: ["--login", "-ci", newCmd, cmdPath] + args, env: ienvs)
//
//	proc.stdout?.switchToNonBlocking()
//	proc.stderr?.switchToNonBlocking()
//
//	var res = -1 as Int32
//	while proc.isOpen() {
//		do {
//			res = try proc.wait(hang: false)
//
//			var writeStr = ""
//			do {
//				while let s = try proc.stdout?.readSomeBytes(count: 2048), s.count > 0 {
//					let str = UTF8Encoding.encode(bytes: s)
//					writeStr.append(str)
//				}
//			} catch PerfectLib.PerfectError.fileError(let code, _) where code == EAGAIN {}
//			if !writeStr.isEmpty {
//				readStdin(writeStr)
//			}
//
//			writeStr = ""
//			do {
//				while let s = try proc.stderr?.readSomeBytes(count: 2048), s.count > 0 {
//					let str = UTF8Encoding.encode(bytes: s)
//					writeStr.append(str)
//				}
//			} catch PerfectLib.PerfectError.fileError(let code, _) where code == EAGAIN {}
//			if !writeStr.isEmpty {
//				readStderr(writeStr)
//			}
//
//			sleep(seconds: 0.25)
//		} catch PerfectLib.PerfectError.fileError(let code, _) {
//			if code != EINTR {
//				break
//			}
//		}
//	}
//
//	return Int(res)
//}

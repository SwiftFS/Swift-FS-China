
run:
	@nohup .build/release/SwiftFSChina serve --env=production
build:
	@swift build && swift build --configuration release
debug:
	@./.build/debug/SwiftFSChina
xcode:
	@swift package generate-xcodeproj
update:
	@swift package update
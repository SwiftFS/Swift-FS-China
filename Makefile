
run:
	@nohup .build/release/SwiftFSChina serve --env=production
build:
	@swift build --configuration release
debug:
	@swift build&&@./.build/debug/SwiftFSChina
xcode:
	@swift package generate-xcodeproj
update:
	@swift package update
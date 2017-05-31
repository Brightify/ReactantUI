.PHONY: xcodeproj

xcodeproj:
	swift package generate-xcodeproj --output ./ReactantUIGenerator.xcodeproj

dev: xcodeproj

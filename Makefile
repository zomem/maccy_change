SHELL := /bin/bash

# 可覆盖：DERIVED、SCHEME、CONFIG、PROJECT
DERIVED ?= ./DerivedData
SCHEME  ?= Maccy
CONFIG  ?= Debug
PROJECT ?= Maccy.xcodeproj
BUNDLE_ID ?= org.p0deje.Maccy.DebugLocal

APP := $(DERIVED)/Build/Products/$(CONFIG)/Maccy.app

.PHONY: build run clean

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) -derivedDataPath $(DERIVED) CODE_SIGNING_ALLOWED=NO build

run: build
	# 关闭已运行的系统版/旧实例，避免冲突
	pkill -x Maccy || true
	# 将调试产物的 Bundle ID 改为本地唯一，避免系统重用已安装版本
	/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier $(BUNDLE_ID)' "$(APP)/Contents/Info.plist" || true
	# 强制以新实例方式启动本地编译版本
	open -n "$(APP)"

clean:
	rm -rf "$(DERIVED)"

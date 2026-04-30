.PHONY: setup analyze format lint test test-coverage gen gen-watch clean build-apk build-aab build-ios upgrade run run-android run-web push-model

# Sentinel — rebuilt only when pubspec.lock changes, skips pub get otherwise
.pub-cache-stamp: pubspec.lock
	flutter pub get
	@touch .pub-cache-stamp

# Smart run targets — pub get only runs when dependencies changed
run: .pub-cache-stamp
	flutter run --dart-define-from-file=.env.json

run-android: .pub-cache-stamp
	emulator -avd Pixel_5_API_34 -window-pos 0 0 0 0 &
	sleep 3
	flutter run -d android --dart-define-from-file=.env.json

run-web: .pub-cache-stamp
	flutter run -d chrome --dart-define-from-file=.env.json

# Bootstrap dev environment (run once after cloning)
setup:
	@./scripts/setup.sh

# Code quality
analyze:
	melos run analyze

format:
	melos run format

lint:
	melos run lint

# Testing
test:
	melos run test

test-coverage:
	melos run test:coverage

# Code generation (freezed, drift, json_serializable)
gen:
	melos run gen

gen-watch:
	melos run gen:watch

# Build
build-apk:
	melos run build:apk

build-aab:
	melos run build:appbundle

build-ios:
	melos run build:ios

# Maintenance
clean:
	melos run clean

upgrade:
	melos run upgrade

outdated:
	melos run outdated

# Push Gemma model to connected Android device (run once after first install)
push-model:
	adb shell mkdir -p /sdcard/Android/data/com.finly.app/files
	adb push assets/models/gemma3-1b-it-int4.task /sdcard/Android/data/com.finly.app/files/gemma3-1b-it-int4.task

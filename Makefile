.PHONY: setup analyze format lint test test-coverage gen gen-watch clean build-apk build-aab build-ios upgrade

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

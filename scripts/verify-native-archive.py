#!/usr/bin/env python3
"""Check repository-controlled contents of a generic iOS/macOS Xcode archive."""

from __future__ import annotations

import argparse
import json
import plistlib
import subprocess
import struct
import sys
from pathlib import Path


CONFIG = {
    "ios": {
        "bundle_id": "io.adambailey.roundgarden",
        "platform": "iPhoneOS",
        "minimum_os": "18.0",
        "resources": Path("."),
        "asset_catalog": Path(
            "apps/ios/Roundgarden/Assets.xcassets/AppIcon.appiconset"
        ),
    },
    "macos": {
        "bundle_id": "io.adambailey.roundgarden",
        "platform": "MacOSX",
        "minimum_os": "15.0",
        "resources": Path("Contents/Resources"),
        "asset_catalog": Path(
            "apps/macos/RoundgardenMac/Assets.xcassets/AppIcon.appiconset"
        ),
    },
}


def read_plist(path: Path) -> dict:
    with path.open("rb") as plist_file:
        value = plistlib.load(plist_file)
    if not isinstance(value, dict):
        raise ValueError(f"Expected a dictionary in {path}")
    return value


def validate_icon_catalog(platform: str) -> list[str]:
    catalog = Path(__file__).resolve().parent.parent / CONFIG[platform]["asset_catalog"]
    contents = json.loads((catalog / "Contents.json").read_text())
    errors = []
    images = contents.get("images", [])
    if not images:
        return [f"{catalog} does not list any icon PNGs"]
    for image in images:
        image_path = catalog / image["filename"]
        data = image_path.read_bytes()
        if (
            len(data) < 33
            or data[:8] != b"\x89PNG\r\n\x1a\n"
            or data[12:16] != b"IHDR"
        ):
            errors.append(f"{image_path} is not a valid PNG")
            continue
        width, height = struct.unpack(">II", data[16:24])
        color_type = data[25]
        if width != height:
            errors.append(f"{image_path} is not square ({width}x{height})")
        if color_type != 2:
            errors.append(f"{image_path} must be opaque RGB (PNG color type 2)")
        if b"tRNS" in data:
            errors.append(f"{image_path} contains a transparency chunk")
    return errors


def check_archive(platform: str, archive: Path, require_signature: bool) -> list[str]:
    expected = CONFIG[platform]
    archive_info = read_plist(archive / "Info.plist")
    properties = archive_info.get("ApplicationProperties", {})
    app_path = archive / "Products" / properties.get("ApplicationPath", "")
    if not app_path.is_dir():
        raise ValueError(f"Archive application is missing: {app_path}")

    app_info_path = app_path / (
        "Info.plist" if platform == "ios" else "Contents/Info.plist"
    )
    app_info = read_plist(app_info_path)
    resource_dir = app_path / expected["resources"]
    privacy_path = resource_dir / "PrivacyInfo.xcprivacy"
    asset_catalog = resource_dir / "Assets.car"
    privacy = read_plist(privacy_path)

    errors = validate_icon_catalog(platform)
    if properties.get("CFBundleIdentifier") != expected["bundle_id"]:
        errors.append(f"archive bundle ID is not {expected['bundle_id']}")
    if app_info.get("CFBundleIdentifier") != expected["bundle_id"]:
        errors.append(f"app bundle ID is not {expected['bundle_id']}")
    if properties.get("CFBundleShortVersionString") != app_info.get(
        "CFBundleShortVersionString"
    ):
        errors.append("archive and app marketing versions differ")
    if properties.get("CFBundleVersion") != app_info.get("CFBundleVersion"):
        errors.append("archive and app build numbers differ")
    if not app_info.get("CFBundleShortVersionString") or not app_info.get(
        "CFBundleVersion"
    ):
        errors.append("marketing version or build number is empty")
    if expected["platform"] not in app_info.get("CFBundleSupportedPlatforms", []):
        errors.append(f"archive does not target {expected['platform']}")
    icon_name = app_info.get("CFBundleIconName")
    if platform == "ios":
        icon_name = (
            app_info.get("CFBundleIcons", {})
            .get("CFBundlePrimaryIcon", {})
            .get("CFBundleIconName")
        )
    if icon_name != "AppIcon":
        errors.append("AppIcon is not configured in the archived app metadata")
    if platform == "macos" and not app_info.get("NSHumanReadableCopyright"):
        errors.append("macOS Info.plist is missing NSHumanReadableCopyright")
    if not asset_catalog.is_file():
        errors.append("compiled asset catalog Assets.car is missing")
    if not privacy_path.is_file():
        errors.append("PrivacyInfo.xcprivacy is missing")
    if privacy.get("NSPrivacyTracking") is not False:
        errors.append("privacy manifest must explicitly declare no tracking")
    if privacy.get("NSPrivacyTrackingDomains") != []:
        errors.append("privacy manifest has unexpected tracking domains")
    if privacy.get("NSPrivacyCollectedDataTypes") != []:
        errors.append("privacy manifest has collected-data declarations to review")

    defaults_api = next(
        (
            api
            for api in privacy.get("NSPrivacyAccessedAPITypes", [])
            if api.get("NSPrivacyAccessedAPIType")
            == "NSPrivacyAccessedAPICategoryUserDefaults"
        ),
        None,
    )
    if not defaults_api or "CA92.1" not in defaults_api.get(
        "NSPrivacyAccessedAPITypeReasons", []
    ):
        errors.append("UserDefaults required-reason declaration CA92.1 is missing")

    minimum_os_key = "MinimumOSVersion" if platform == "ios" else "LSMinimumSystemVersion"
    if app_info.get(minimum_os_key) != expected["minimum_os"]:
        errors.append(
            f"minimum OS should be {expected['minimum_os']}, "
            f"found {app_info.get(minimum_os_key)!r}"
        )

    signature = subprocess.run(
        ["codesign", "--verify", "--deep", "--strict", str(app_path)],
        capture_output=True,
        text=True,
        check=False,
    )
    if signature.returncode == 0:
        signed_entitlements = subprocess.run(
            ["codesign", "-d", "--entitlements", ":-", str(app_path)],
            capture_output=True,
            check=False,
        )
        if signed_entitlements.returncode != 0:
            errors.append("could not read code-signing entitlements")
        elif platform == "macos":
            entitlements = plistlib.loads(signed_entitlements.stdout)
            if entitlements.get("com.apple.security.app-sandbox") is not True:
                errors.append("signed macOS app is missing the required App Sandbox entitlement")
    elif require_signature:
        errors.append("archive app is not code signed and verified")

    print(
        f"{platform}: {properties.get('CFBundleIdentifier')} "
        f"{properties.get('CFBundleShortVersionString')} "
        f"({properties.get('CFBundleVersion')})"
    )
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("platform", choices=CONFIG)
    parser.add_argument("archive", type=Path, help="Path to the .xcarchive")
    parser.add_argument(
        "--require-signature",
        action="store_true",
        help="require a valid code signature; a developer signing identity still needs manual confirmation",
    )
    args = parser.parse_args()

    try:
        errors = check_archive(args.platform, args.archive, args.require_signature)
    except (OSError, plistlib.InvalidFileException, ValueError) as error:
        print(f"archive check failed: {error}", file=sys.stderr)
        return 1

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print("archive contents are ready for the next signing/release checks")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

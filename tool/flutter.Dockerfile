# Flutter + Android SDK for building and testing the Android app on Linux
# without installing either locally:
#
#   docker build -t durys-soile-flutter -f tool/flutter.Dockerfile tool
#   docker run --rm -v "$PWD":/app -w /app durys-soile-flutter flutter test
#
# The Android SDK comes from CirrusLabs' image; Flutter itself is replaced
# with the official release this project pins (the same version the CI uses
# for iOS), verified against the checksum Google publishes for it.
FROM ghcr.io/cirruslabs/flutter:3.44.0@sha256:46691e311715845de03a3ba4753a475476936805b29431b1f00f1816981033f8

ARG FLUTTER_VERSION=3.47.5
ARG FLUTTER_SHA256=2132e990f236f8d22e7c6314b29a191a95b10d7cbcfec9b4e2e303d996652cbb
# Override to fetch the archive from elsewhere, e.g. a copy served locally
# (the checksum is verified either way).
ARG FLUTTER_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# The archive is about 1.5 GB: retry and resume, since long downloads over a
# flaky connection often break partway.
RUN for attempt in 1 2 3 4 5 6; do \
        curl -fsSL --retry 5 --retry-all-errors -C - -o /tmp/flutter.tar.xz "${FLUTTER_URL}" && break; \
        echo "download interrupted, resuming (attempt ${attempt})"; \
    done \
    && echo "${FLUTTER_SHA256}  /tmp/flutter.tar.xz" | sha256sum -c - \
    && rm -rf /sdks/flutter \
    && tar -xJf /tmp/flutter.tar.xz -C /sdks \
    && rm /tmp/flutter.tar.xz \
    && git config --global --add safe.directory /sdks/flutter \
    && flutter config --no-analytics --no-cli-animations \
    && flutter precache --android \
    && flutter --version

# SDK components the Android build needs beyond the base image (Flutter's
# default NDK, and what its plugins build with), so builds do not download
# them into the throwaway container every time.
RUN yes | sdkmanager --install "platforms;android-35" "cmake;3.22.1" "ndk;28.2.13676358" > /dev/null \
    && sdkmanager --list_installed | grep -E "ndk|cmake|platforms"

#!/bin/sh

# github-cli: for github
# butler: for itchio

GAME="the-roadtrip"
VERSION="$(git tag --points-at HEAD)"

if [[ -z "$VERSION" ]]; then
    echo "No version tag found. Aborting."
    exit 1
fi

CHANNELS=("linux" "win" "web" "macOS")

build_channels() {
    for CHANNEL in "${CHANNELS[@]}"; do
        echo "Building channel $CHANNEL"
        rm build/$CHANNEL -rf
        ./scripts/build-channel.sh $CHANNEL
    done
}

github_release() {
    echo "Releasing version $VERSION to github"

    cd build
    mkdir -p gh-releases
    for CHANNEL in "${CHANNELS[@]}"; do
        echo "Archiving $CHANNEL"
        cp $CHANNEL $GAME -r
        zip -r gh-releases/$GAME-$CHANNEL.zip $GAME
        rm $GAME -rf
    done

    echo "Creating release"
    gh release create $VERSION gh-releases/* -n "$CHANGELOG" -t ""
    rm gh-releases -rf
}

itch_release() {
    echo "Releasing version $VERSION to itch.io"

    for CHANNEL in "${CHANNELS[@]}"; do
        echo "Releasing $CHANNEL"
        butler push build/$CHANNEL kuma-gee/$GAME:$CHANNEL --userversion $VERSION
    done
}

VERSION_REGEX='^v[0-9]+\.[0-9]+'
if [[ $VERSION =~ $VERSION_REGEX ]]; then
    build_channels
    itch_release
    github_release
else
    build_channels
    echo "Missing or invalid version. Publish skipped."
fi

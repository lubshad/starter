#!/bin/bash

echo "🚀 Starting release process..."
echo ""

# Run version increment script
./version_increment.sh

echo ""
echo "📱 Building and releasing to stores..."
echo ""

# Release to Play Store
echo "📦 Building for Play Store..."
./playstorerelease.sh

echo ""
echo "🍎 Building for App Store..."
# Release to App Store
./appstorerelease.sh

echo ""
echo "✅ Release process completed!"
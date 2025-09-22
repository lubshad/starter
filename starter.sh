#!/bin/bash
set -e

echo "🚀 Starting Flutter project setup..."

# Prompt for project name
echo "📝 Step 1: Getting project details"
read -p "Enter the project name: " project_name

# Prompt for organization name
read -p "Enter the organization name (in reverse domain format, e.g., com.example): " org_name

echo "✅ Project details collected: $project_name (org: $org_name)"

# Create Flutter project
echo "🔨 Step 2: Creating Flutter project..."
flutter create --org $org_name $project_name
echo "✅ Flutter project created successfully"

# Clone repository
echo "📥 Step 3: Cloning starter repository..."
cd $project_name
git clone https://github.com/lubshad/starter.git
echo "✅ Starter repository cloned"

# Copy files from the starter repository
echo "📋 Step 4: Copying starter files..."
cp -r starter/lib .
cp -r starter/assets .
cp -r starter/version_increment.sh version_increment.sh
cp -r starter/playstorerelease.sh playstorerelease.sh
cp -r starter/appstorerelease.sh appstorerelease.sh
cp -r starter/playstore_and_appstore_release.sh playstore_and_appstore_release.sh

echo "✅ Starter files copied (lib and assets scripts)"

# Remove the starter repository
echo "🧹 Step 5: Cleaning up..."
rm -rf starter
echo "✅ Starter repository removed"

# Add Flutter packages
echo "📦 Step 6: Adding Flutter packages..."
flutter pub add carousel_slider pretty_dio_logger sqflite agora_chat_uikit iconsax flutter_secure_storage timeago audio_waveforms audioplayers flutter_callkit_incoming agora_rtc_engine flutter_screenutil pretty_dio_logger open_file flutter_in_app_pip mime google_mlkit_barcode_scanning camera dio dartz flutter_spinkit pinput google_sign_in country_code_picker firebase_auth firebase_core firebase_analytics flutter_svg animations jwt_decoder get hive path_provider flutter_animate firebase_messaging battery_plus webview_flutter firebase_crashlytics gap lottie device_info_plus package_info_plus file_picker image_picker image_cropper url_launcher cloud_firestore intl geolocator geocoding dotted_border cached_network_image flutter_foreground_task infinite_scroll_pagination toastification dio_cookie_manager auto_size_text connectivity_plus flutter_local_notifications permission_handler google_maps_flutter screen_protector flutter_activity_recognition agora_chat_sdk
echo "✅ Flutter packages added successfully"

# Open in editors
echo "🔧 Step 7: Opening project in editors..."
cursor .

echo "🎉 Setup complete! Your Flutter project '$project_name' is ready to go!"

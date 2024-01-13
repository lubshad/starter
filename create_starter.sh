    #!/bin/bash

# Prompt for project name
read -p "Enter the project name: " project_name

# Prompt for organization name
read -p "Enter the organization name (in reverse domain format, e.g., com.example): " org_name

# Create Flutter project
flutter create --org $org_name $project_name

# Clone repository
cd $project_name
git clone https://github.com/lubshad/starter.git

# Copy files from the starter repository
cp -r starter/lib .
cp -r starter/assets .

# Remove the starter repository
rm -rf starter

# Add Flutter packages
flutter pub add dio dartz flutter_spinkit pinput  country_code_picker  firebase_auth  firebase_core firebase_analytics flutter_svg  animations  jwt_decoder  get  hive  path_provider
code .


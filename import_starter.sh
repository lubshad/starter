git clone https://github.com/lubshad/starter.git &&
cp -r starter/lib . &&
rm -rf starter &&
echo "
  dio: ^5.3.2
  dartz: ^0.10.1
  flutter_spinkit: ^5.2.0
  pinput: ^3.0.0
  country_code_picker: ^3.0.0
  firebase_auth: ^4.7.2" >> pubspec.yaml

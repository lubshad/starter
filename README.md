# Flutter Starter Template

Welcome to the Flutter Starter Template, a quick and easy way to kickstart your Flutter projects. Follow the steps below to set up your project effortlessly.

## Getting Started

1. **Copy Content from `create_starter.sh`**

   Open your terminal and navigate to the folder where all your Flutter projects are located. Then, create a new file named `create_starter.sh` and paste the content from the provided script.

2. **Open Terminal**

   ```bash
   cd path/to/flutter/projects
   nano create_starter.sh

3. **Give permission for execution**
   ```bash
    chmod +x create_starter.sh

4. **Execute the script**
   ```bash
    ./create_starter.sh
    
    "script will ask for your project details ..."

5. **Add Project in Firebase(OPTIONAL)**

6. **Set main.dart to main_local.dart**
   Add entrypoint main_local.dart
   ```bash
         {
            "name": "project_name",
            "request": "launch",
            "type": "dart",
            "program": "lib/main_local.dart"
        },


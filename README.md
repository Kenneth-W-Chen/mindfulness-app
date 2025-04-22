# Mindfulness App

The purpose of this project is to develop a platform in which users are provided with various avenues to practice mindfulness techniques, enhance their emotional awareness, and manage their stress. Users are encouraged to authentically engage with their emotions through guided content, whilst being offered tools to track and reflect on their emotional state.

The intended audience is primarily children ages 9- to 14-years old.

# Device requirements

This app was built and tested on
* Android 15 (API 35)

# Setting up the project
Ensure you have the flutter SDK installed and updated. To update the SDK, run

```shell
flutter upgrade
```

Clone the repository, navigate to the base directory of the repository, and run

```shell
flutter create --project-name <project_name> .
```

where `<project_name>` is the name of the application in all lower case and no spaces or hyphens.

# Building

To build the project for Android, run

```shell
flutter build appbundle
```

To build for iOS, run

```shell
flutter build ios
```

*Note: this command will only run on a device running MacOS with Xcode installed.*
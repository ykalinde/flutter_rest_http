## About Package

Simple package to integrate to JSON based rest API

## Getting started

Run the following command to install the package in your project

```
flutter pub add flutter_rest_http
```

## Usage

### 1. Import Package
```dart
import 'package:flutter_rest_http/flutter_rest_http.dart';
```

### 2. Initialization

In your main method in `lib/main.dart` add the following block

```dart
void main(){
    RestHttp.init(
        baseURL: "https://jsonplaceholder.typicode.com/"
    );
}

```

### 3. Make GET Request

```dart
void getPosts(){
  RestHttp.get("posts").then((res) {
    //handle response
  }).catchError((err, stack) {
    //handle errors
  });
}
```

### 4. Make POST Request

```dart
void createPost(){
  RestHttp.post("posts", params: {
    "title": "New post",
    "body": "Post description body"
  }).then((res) {
    //handle response
  }).catchError((err, stack) {
    //handle errors
  });
}

```

## About Package

Simple package to integrate to JSON based rest API

## Getting started

Run the following command to install the package in your project

```
flutter pub get flutter_rest_http
```

## Usage

### 1. Initialization

In your main method in `lib/main.dart` add the following block

```
void main(){
    RestHttp.init(
        baseURL: "https://jsonplaceholder.typicode.com/"
    );
}

```

### 2. Make GET Request

```
RestHttp.get("posts").then((res) {
    //handle response
}).catchError((err, stack) {
   //handle errors
});
```

### 3. Make POST Request

```
RestHttp.post("posts", params: {
    "title": "New post",
    "body": "Post description body"
}).then((res) {
    //handle response
}).catchError((err, stack) {
   //handle errors
});
```

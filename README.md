# Flutter Test Application: OpenID Connect Integration

## Introduction

The goal of this test is to evaluate the candidate's knowledge of working with modern authentication protocols, specifically **OpenID Connect (OIDC)**, within the context of a mobile application. This test focuses on implementing the **frontend part** of the OIDC Authorization Code Flow using the provided demo server.

To successfully complete the task, the candidate is expected to demonstrate an understanding of OIDC concepts or be able to research and learn the necessary information independently. This includes, but is not limited to, working with authorization endpoints, token exchange, and securely handling tokens in a mobile application.

### Key Concepts to Explore

Candidates should familiarize themselves with the following topics:
1. **OpenID Connect Overview**:
   - [Introduction to OpenID Connect](https://openid.net/connect/)
   - [Authorization Code Flow with PKCE](https://auth0.com/docs/authenticate/protocols/oauth/oauth-authorization-code-flow)

2. **State Management in Flutter**:
   - [Bloc State Management](https://bloclibrary.dev/#/)

3. **Navigation in Flutter**:
   - [go_router Package](https://pub.dev/packages/go_router)

4. **API Requests**:
   - [dio Package](https://pub.dev/packages/dio)

### Self-Learning Expectation

The candidate is expected to research and identify appropriate solutions independently, including:
- Using any appropriate package for OIDC integration.
- Implementing `Bloc` for state management.
- Configuring `go_router` for navigation between authorized and unauthorized views.
- Using `dio` with interceptors to manage API requests and inject tokens.

---

## Requirements

### Functional Requirements

1. **Authorization via Code Flow**
   - Implement the **Authorization Code Flow with PKCE** to authenticate with the [demo server](https://demo.duendesoftware.com/).
   - Use the provided native client (`interactive.public`) for login.
   - Retrieve and securely store the **access token**, **ID token**, and **refresh token** upon successful authorization.

2. **Protected API Access**
   - Use the **access token** to fetch data from a protected API endpoint.
   - Display the retrieved data (e.g., user profile or demo-provided data) in the app.

3. **Token Refresh**
   - Implement periodic token refresh using the **refresh token**.
   - Automatically refresh the access token before it expires.
   - Display updated tokens in the logs or UI for demonstration purposes.

### Additional Functional Requirements

1. **State Management**
   - Use the **Bloc library** to handle the state of the application.
   - Manage states such as unauthorized, authenticating, authorized, and token refreshing.

2. **Navigation**
   - Use **go_router** for navigation.
   - Redirect users to a login page if they are unauthorized.
   - Navigate to the authorized home page after successful login.

3. **API Requests**
   - Use **dio** to handle all API requests.
   - Configure a **dio interceptor** to automatically inject the access token into the headers of all authorized requests.

4. **Logout Functionality**
   - Implement a logout feature that:
     - Clears stored tokens and session data.
     - Redirects the user to the login page.

---

## Technical Requirements

1. **Flutter Libraries**
   - Use the following libraries:
     - any appropriate package for OIDC flows.
     - `flutter_bloc` for state management.
     - `go_router` for navigation.
     - `dio` for API requests.

2. **Secure Token Handling**
   - Store tokens securely.
   - Ensure tokens are not exposed in logs or UI unnecessarily.

3. **Error Handling**
   - Gracefully handle errors during authorization, API requests, and token refresh.
   - Provide user-friendly error messages where appropriate.

4. **UI/UX**
   - Simple and functional UI with:
     - **Login Page**: Includes a login button to start the OIDC flow.
     - **Home Page**: Displays user data fetched from the protected API.
     - **Error Notifications**: Displays errors when applicable.

---

## Deliverables

1. **Flutter Project Code**
   - Submit the complete Flutter project.
   - Include a `README.md` with setup instructions, including configuration of the redirect URI and running the app.
---

## Evaluation Criteria

1. **Functionality**:
   - Does the app implement the OIDC Authorization Code Flow with PKCE?
   - Are authorized API requests and token refresh handled correctly?

2. **Use of Libraries**:
   - Is `Bloc` used appropriately for state management?
   - Does `go_router` handle navigation effectively?
   - Is `dio` used with an interceptor to inject access tokens?

3. **Code Quality**:
   - Is the code clean, modular, and maintainable?
   - Are secure coding practices followed?

4. **User Experience**:
   - Is the UI intuitive and functional?
   - Are errors handled gracefully?

---

By completing this test, candidates can showcase their knowledge of OIDC, state management, navigation, and API integration in Flutter. Successful implementation will demonstrate problem-solving skills, self-learning capability, and adherence to best practices.

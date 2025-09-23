# EAS Authentication and Mobile App Deployment Setup

## Overview
This document provides instructions for setting up EAS (Expo Application Services) authentication and deploying the Nexus COS mobile application.

## Prerequisites
- ✅ EAS CLI installed (version 16.19.3)
- ✅ Mobile app dependencies installed
- ✅ EAS configuration file created (eas.json)
- 📱 Expo account (required for authentication)

## Current Status
- **EAS CLI**: Installed and ready
- **Configuration**: eas.json created with development, preview, and production builds
- **Dependencies**: Mobile app dependencies installed
- **Authentication**: Pending user login

## Next Steps

### 1. EAS Authentication
To authenticate with EAS, run the following command in the mobile directory:
```bash
eas login
```
This will prompt you to:
- Enter your Expo account credentials
- Or create a new Expo account if you don't have one

### 2. Project Configuration
After authentication, initialize the EAS project:
```bash
eas project:init
```

### 3. Build Configuration
The following build profiles are configured in `eas.json`:

#### Development Build
```bash
eas build --profile development --platform android
eas build --profile development --platform ios
```

#### Preview Build
```bash
eas build --profile preview --platform android
eas build --profile preview --platform ios
```

#### Production Build
```bash
eas build --profile production --platform android
eas build --profile production --platform ios
```

### 4. Submit to App Stores
For production deployment:
```bash
eas submit --platform android
eas submit --platform ios
```

## Configuration Files

### app.json
- App name: "Nexus COS Mobile"
- Bundle ID: com.nexus.cos
- EAS Project ID: nexus-cos-mobile

### eas.json
- Development builds with internal distribution
- Preview builds for testing
- Production builds for app store submission

## Environment Variables
The mobile app can connect to the backend API at:
- **Backend Node.js**: http://localhost:3002
- **Backend Python**: http://localhost:3001 (when available)

## Troubleshooting

### Common Issues
1. **Authentication Failed**: Ensure you have a valid Expo account
2. **Build Errors**: Check that all dependencies are properly installed
3. **Platform Issues**: Ensure you have the required development tools for iOS/Android

### Support
- Expo Documentation: https://docs.expo.dev/
- EAS Build Documentation: https://docs.expo.dev/build/introduction/
- EAS Submit Documentation: https://docs.expo.dev/submit/introduction/

## Security Notes
- Keep your Expo account credentials secure
- Use environment variables for sensitive configuration
- Review build logs for any exposed secrets

---
**Status**: Ready for user authentication
**Next Action**: Run `eas login` to authenticate with Expo
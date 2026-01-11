# Firebase Initialization Guide

## N3XUS v-COS Firebase Mirror Setup

This document provides instructions for setting up Firebase Firestore as an observational mirror for N3XUS v-COS billing data.

### Project Setup

1. Create a new Firebase project or use existing project
2. Enable Firestore Database
3. Set security rules to allow read/write from authorized services only

### Collection Setup

Create a Firestore collection named: `n3xus_billing_snapshot`

### Fields Schema

Refer to `firebase.schema.json` for complete field definitions.

### Integration

Use `firebase.mirror.ts` to transform ledger data before writing to Firestore.

### Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /n3xus_billing_snapshot/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.role == 'system';
    }
  }
}
```

### Environment Variables

Set the following in your environment:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_CLIENT_EMAIL`

### Deployment

The snapshot service runs independently and mirrors ledger data to Firebase on a scheduled basis.

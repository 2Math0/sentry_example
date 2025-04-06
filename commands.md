## Sentry Commands

### create release

```bash
# Install the cli
curl -sL https://sentry.io/get-cli/ | bash

# Setup configuration values
SENTRY_AUTH_TOKEN=2ffe3389c11fcc86a45ebfc2e145315653ac292301dcb61e830b7865f4b5830d # From internal integration: flutter Release Integration
SENTRY_ORG=ashtar
SENTRY_PROJECT=project
VERSION=`sentry-cli releases propose-version`

# Workflow to create releases
sentry-cli releases new "$VERSION"
sentry-cli releases set-commits "$VERSION" --auto
sentry-cli releases finalize "$VERSION"
```
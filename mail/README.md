# Mail Fabric System

## Purpose

Business email as an IMVU service, not a shared tool. Every mailbox is identity-bound and IMVU-scoped.

## Components

- **SMTP Server:** Ingress/egress for email
- **IMAP Server:** Mailbox storage and access
- **DKIM/SPF/DMARC:** Email authentication
- **Identity Binding:** Mailboxes bound to identities
- **Isolation:** No cross-IMVU leakage

## Key Principle

```
creator@imvu042.world → identity + IMVU + revenue routing
```

## Architecture

```
Incoming Mail
    ↓
SMTP Server (identity-gated)
    ↓
Mailbox Storage (IMVU-isolated)
    ↓
IMAP Server (identity-authenticated)
```

## Enforcement

- Every message is attributable to identity
- Every mailbox has ownership (identity + IMVU)
- Every outbound action can be policy-checked
- All mail actions logged to ledger

## Implementation Status

- [ ] SMTP ingress/egress
- [ ] IMAP storage
- [ ] DKIM/SPF/DMARC automation
- [ ] Identity binding
- [ ] IMVU isolation

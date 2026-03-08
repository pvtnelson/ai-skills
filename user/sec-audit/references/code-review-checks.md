# Code Security Review Checklist

Apply the relevant sections based on the stack detected in Step 1.

## Authentication & Session Management
- [ ] Token/session validation on every protected endpoint or route
- [ ] Session tokens are cryptographically random (>128 bits entropy)
- [ ] JWT: algorithm explicitly set (no `alg:none`), short expiry, audience/issuer validated
- [ ] Passwords hashed with adaptive function: argon2id, bcrypt (cost ≥12), or PBKDF2 (≥100K iterations)
- [ ] Rate limiting on login, register, password reset, MFA verification
- [ ] Account lockout or exponential backoff after failed attempts
- [ ] Cookie flags: HttpOnly, Secure, SameSite=Lax or Strict
- [ ] CORS locked to specific origins (not `*` on credentialed requests)
- [ ] Anti-enumeration: login/register return same response for valid/invalid users

## Authorization & Access Control
- [ ] Role/permission check on every privileged operation (not just UI hiding)
- [ ] Vertical escalation: regular user cannot access admin endpoints
- [ ] Horizontal escalation: user A cannot access user B's resources (IDOR)
- [ ] API endpoints without authentication middleware identified
- [ ] Resource ownership validated server-side (not just by client-sent user ID)
- [ ] Default deny: new endpoints require explicit auth by default
- [ ] Multi-tenancy: tenant isolation enforced at database level (RLS, WHERE clauses)

## Input Validation & Injection
- [ ] SQL: parameterized queries only, no string interpolation/concatenation
- [ ] XSS: user content HTML-escaped on output, CSP headers set
- [ ] Command injection: no user input in shell commands (or properly escaped)
- [ ] Path traversal: file operations sanitize `../` and null bytes
- [ ] SSRF: user-supplied URLs validated against allowlist, no internal network access
- [ ] File uploads: type validated (magic bytes, not just extension), size limited, filename sanitized
- [ ] Deserialization: untrusted data not deserialized with unsafe methods (pickle, yaml.load, eval)
- [ ] Template injection: user input not passed to template engines as template code
- [ ] Regex DoS (ReDoS): no unbounded backtracking in user-facing regex

## Data Protection
- [ ] PII encrypted at rest (not just the database volume — field-level where appropriate)
- [ ] Encryption keys derived properly (KDF, not plain hash)
- [ ] No sensitive data in logs (mask passwords, tokens, PII in log statements)
- [ ] Secrets from environment variables or vault, not config files or source code
- [ ] Database backups encrypted
- [ ] Sensitive data not cached in browser (Cache-Control: no-store on auth responses)
- [ ] Error messages do not leak stack traces, SQL queries, or internal paths to users

## API Security
- [ ] Rate limiting on all public endpoints
- [ ] Request size limits configured
- [ ] API versioning does not expose deprecated insecure endpoints
- [ ] GraphQL: query depth/complexity limits, introspection disabled in production
- [ ] Webhook endpoints verify signatures
- [ ] CSRF protection on state-changing requests (token or SameSite cookies)

## Cryptography
- [ ] TLS 1.2+ enforced (no SSLv3, TLS 1.0, TLS 1.1)
- [ ] Strong cipher suites only (no RC4, DES, 3DES, export ciphers)
- [ ] Random number generation uses cryptographic RNG (not Math.random/random.random for security)
- [ ] No custom/homebrew cryptographic implementations
- [ ] Certificate validation not disabled (no `verify=False`, `NODE_TLS_REJECT_UNAUTHORIZED=0`)

## Logging & Monitoring
- [ ] Authentication events logged (login, logout, failed attempts, MFA)
- [ ] Authorization failures logged with user context
- [ ] Sensitive operations logged (admin actions, data export, privilege changes)
- [ ] Log injection prevented (user input sanitized before logging)
- [ ] No secrets or tokens in log output

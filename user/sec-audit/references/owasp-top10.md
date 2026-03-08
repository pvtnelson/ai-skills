# OWASP Top 10 (2021) — Quick Reference

Use this to classify findings. Map each security issue to the most relevant category.

| ID | Category | Description | Common CWEs |
|----|----------|-------------|-------------|
| **A01:2021** | Broken Access Control | Missing or bypassed authorization checks. IDOR, privilege escalation, CORS misconfiguration, force browsing. | CWE-200, CWE-284, CWE-285, CWE-352, CWE-639 |
| **A02:2021** | Cryptographic Failures | Weak/missing encryption, plaintext transmission, weak hashing, hardcoded keys, poor randomness. | CWE-259, CWE-261, CWE-327, CWE-328, CWE-330 |
| **A03:2021** | Injection | SQL injection, NoSQL injection, OS command injection, LDAP injection, XSS (moved here from its own category). | CWE-20, CWE-74, CWE-75, CWE-77, CWE-78, CWE-79, CWE-89 |
| **A04:2021** | Insecure Design | Missing threat modeling, insecure business logic, no rate limiting by design, missing security controls architecture. | CWE-209, CWE-256, CWE-501, CWE-522 |
| **A05:2021** | Security Misconfiguration | Default credentials, unnecessary features enabled, overly permissive error messages, missing security headers, unpatched systems. | CWE-2, CWE-11, CWE-13, CWE-15, CWE-16, CWE-388 |
| **A06:2021** | Vulnerable and Outdated Components | Using components with known vulnerabilities, unpatched libraries, unsupported frameworks. | CWE-1104 |
| **A07:2021** | Identification and Authentication Failures | Weak passwords allowed, missing MFA, session fixation, credential stuffing, insecure password recovery. | CWE-255, CWE-259, CWE-287, CWE-288, CWE-384 |
| **A08:2021** | Software and Data Integrity Failures | Unsigned updates, untrusted CI/CD pipelines, insecure deserialization, dependency confusion. | CWE-345, CWE-353, CWE-426, CWE-494, CWE-502, CWE-565, CWE-784, CWE-829 |
| **A09:2021** | Security Logging and Monitoring Failures | Missing audit trails, logs not covering security events, no alerting for suspicious activity, insufficient log retention. | CWE-117, CWE-223, CWE-532, CWE-778 |
| **A10:2021** | Server-Side Request Forgery (SSRF) | Application fetches remote resources using user-supplied URLs without validation, enabling internal network scanning or cloud metadata access. | CWE-918 |

## Severity Mapping

When a finding maps to multiple OWASP categories, use the one with the most direct impact:
- Access control bypass → A01 (even if it also involves injection)
- Known CVE in a dependency → A06 (primary), plus the attack category
- Hardcoded secret → A02 (cryptographic failure)
- Missing input validation → A03 if injectable, A04 if design flaw

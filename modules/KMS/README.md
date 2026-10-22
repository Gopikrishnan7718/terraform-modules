# KMS Module

This module creates a reusable AWS customer-managed KMS key for encryption.

## Responsibilities

The module is responsible for:

- Creating a customer-managed symmetric KMS key
- Creating a KMS alias
- Enabling automatic key rotation
- Configuring the KMS key deletion waiting period
- Applying a baseline KMS key policy
- Applying standardized resource tags
- Exposing the key ID, key ARN, alias name, and alias ARN

The module does not contain service-specific permissions for S3, RDS, EBS,
CloudWatch Logs, or other AWS services.

Service-specific KMS permissions must be managed by the consuming module.

---

## Architecture

```text
                    +----------------------+
                    |      KMS Module      |
                    +----------+-----------+
                               |
                +--------------+--------------+
                |                             |
                v                             v
       Customer-managed key              KMS alias
       ENCRYPT_DECRYPT             alias/<name>-kms-key
                |
                |
                v
       Baseline key policy
                |
                v
       AWS account principal
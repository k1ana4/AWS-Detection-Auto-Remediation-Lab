# ADR 0002 — Detection Source Selection

## Status
Accepted

## Context
The lab needs to detect two different kinds of problem: resources that are
configured badly and activity that looks like an attack. No single AWS service 
covers both, so we picked a set and justified it. Cost was a hard constraint, 
so this runs on a personal account with limited credits, 
and several of these services bill per unit of work.

## Decision
Five sources, each covering a distinct angle:

- **CloudTrail** : records API calls. Required, because EventBridge can't see
  `AWS API Call` events at all without a trail in the region.
- **GuardDuty** : threat detection from logs we don't have to configure.
  Publishing frequency set to `FIFTEEN_MINUTES`.
- **Security Hub** : aggregates findings into one format and runs posture
  checks. AWS Foundational Security Best Practices standard only.
- **AWS Config** : records resource configuration changes. Most Security Hub
  controls are Config-rule-backed, so without a recorder the dashboard is
  empty. Scoped to five resource types.
- **IAM Access Analyzer** : finds resource policies granting external access.
  ACCOUNT type only.

## Consequences

**Why FSBP only.** CIS and PCI overlap heavily with FSBP, and Security Hub
bills per check. Adding standards multiplies cost without adding meaningful
coverage for a lab this size.

**Why Config is scoped.** `all_supported = true` records every resource type,
and Config bills per configuration item. In an account where we deliberately
create and destroy resources, that's the single largest cost risk in the
project. Scoped to security groups, EC2 instances, S3 buckets, IAM policies,
and IAM roles are the five types our remediations actually touch.

**Why fifteen-minute publishing.** The default batches finding updates for six
hours. First occurrences publish immediately, so a demo works either way, but
ongoing activity would appear frozen. Fifteen minutes is the shortest interval
GuardDuty allows.

**Why ACCOUNT-type Access Analyzer.** The external-access analyzer is free. The
unused-access analyzer is priced per resource and answers a question this lab
isn't asking.

**Account plan constraint.** The AWS Free plan blocks GuardDuty and Security Hub
outright and both returned `SubscriptionRequiredException` on first apply. The lab
account had to move to the Paid plan before the detection layer could deploy.

**What we gave up.** No VPC Flow Logs as a separate source as GuardDuty consumes
them internally, but we can't query them directly. No Macie, Inspector, or
Detective since they are all priced beyond the lab budget.

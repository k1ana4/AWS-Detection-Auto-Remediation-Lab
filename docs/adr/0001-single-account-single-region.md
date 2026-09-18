# ADR 0001: Single Account, Single Region

## Context

This project needs a detection and auto-remediation pipeline that we can intentionally break and rebuild many times.

In a real company, this stack would be run across many AWS accounts. One account holds the security tools, others hold the actual workloads, and the security account reaches into them to fix problems. This way, the tools are separate from what they are monitoring.

We do not have access to AWS Organizations, and every extra account/region costs more. GuardDuty, Security Hub, and Config are all billed per region. We each have our own IAM user in a group with the attached AdministratorAccess policy rather than scoped permissions.

## Decisions

One AWS account and one static region (`us-east-2`). CloudTrail, GuardDuty, Security Hub, Config, Access Analyzer, test environment, and the Lambdas.

CloudTrail is the only one watching beyond a single region. The trail lives in `us-east-2` but is set to `multi-region`, so it still records API activity in regions we do not use. 

## Tradeoffs

**Pros:**

Cost is cheap and rebuild is quick and seamless. It can be torn down and recreated often, which we take advantage of to catch problems that only show up on a fresh build.

**Cons:**

The environment is dissimilar to an actual deployment. We do not learn cross-account setup, and our remediation Lambdas will sit in the same account as the things they are fixing. If somebody were to compromise the account, they would compromise the remediation tools as well.

Both of us having AdministratorAccess is not something we would do outside of a lab environment. A real deployment would scope each identity to what it actually needs.

There is also a likely detection gap. The trail records activity in every region, but GuardDuty, Security Hub, and Config are all single-region, so nothing outside `us-east-2` should trigger a finding or remediation. We would expect to end up with a log entry and no response. We have not tested this yet. Further confirmation is needed once detection is up by creating something in another region and seeing what notices.

# Terraform Limitations and Boundaries

This document describes which parts of the AKS monitoring task cannot be fully automated using Terraform and why.

## 1. Kubernetes Operational Commands

Terraform does not execute operational Kubernetes commands such as:

- az aks get-credentials
- kubectl apply
- kubectl get pods --watch
- kubectl get service --watch

Terraform is a declarative Infrastructure as Code tool, not an operational runtime tool. 
In production environments, Terraform replaces kubectl by managing Kubernetes resources declaratively or via Helm.

## 2. Runtime Validation and Waiting Logic

Terraform does not wait for:

- Pods to reach Running state
- Services to receive an EXTERNAL-IP
- Application readiness or health checks

These are runtime concerns handled by Kubernetes controllers and operators, not IaC tools.

## 3. Cloud Shell Interaction

Terraform cannot:

- Copy files into Azure Cloud Shell
- Interact with user shell sessions
- Perform guided lab steps

These actions are training-oriented and outside Terraform's scope.

## 4. Visual Evidence and Reporting

Terraform cannot:

- Take screenshots of dashboards or workbooks
- Capture alert emails
- Generate PDFs
- Upload files to learning portals

These steps require human validation and are intentionally manual.

## 5. Alert Trigger Simulation

Terraform defines alert rules but does not:

- Trigger alerts intentionally
- Simulate pod failures
- Capture alert notifications

Alert testing must be performed manually or via controlled fault injection.

## Summary

Terraform is responsible for:
- Infrastructure provisioning
- Configuration management
- Monitoring setup
- Alerts, dashboards, and RBAC

Terraform is not responsible for:
- Operational verification
- Runtime observation
- Human validation artifacts
- Training platform submissions

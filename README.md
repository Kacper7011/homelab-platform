# homelab-platform

> Personal platform engineering project – work in progress.

## Overview

This repository documents my homelab platform built on a 3-node Proxmox cluster.

The goal of this project is:

- to document my infrastructure
- to apply modern DevOps and Platform Engineering practices
- to build a reproducible and automated environment
- to have a single source of truth for my setup
- to be able to rebuild everything from scratch

This is an ongoing project and is constantly evolving.

---

## High-Level Architecture

The platform consists of:

- 3 Proxmox nodes (cluster)
- Multiple virtual machines
- k3s Kubernetes cluster
- GitOps-based deployments
- CI/CD pipelines
- Platform services (monitoring, ingress, storage, etc.)
- Self-hosted workloads
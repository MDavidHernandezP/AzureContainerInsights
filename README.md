# Azure Monitor Lab 3 - Container Insights & AKS Monitoring

[![Azure](https://img.shields.io/badge/Microsoft%20Azure-Cloud-0078D4.svg?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![AKS](https://img.shields.io/badge/Azure%20Kubernetes-Service-326CE5.svg?logo=kubernetes&logoColor=white)](https://azure.microsoft.com/en-us/services/kubernetes-service/)
[![Container Insights](https://img.shields.io/badge/Container%20Insights-Monitoring-0078D4.svg)](https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5.svg?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Metrics-E6522C.svg?logo=prometheus&logoColor=white)](https://prometheus.io/)

This repository demonstrates comprehensive container and Kubernetes monitoring using Azure Container Insights for Azure Kubernetes Service (AKS). The project includes multi-node pool AKS cluster provisioning (Linux and Windows), application deployment, Container Insights enablement with Prometheus metrics, pod-level alerting, custom dashboards, and interactive workbooks for cluster analysis.

## Overview

This lab implements enterprise-grade Kubernetes monitoring using Azure Container Insights, covering cluster health, node performance, pod status, and container metrics. The project provisions a production-ready AKS cluster with both Linux and Windows node pools, deploys sample applications, enables Container Insights with Prometheus integration, creates sophisticated alerting rules for pod availability, and builds comprehensive visualization tools for cluster observability.

### What This Project Demonstrates

- **AKS Cluster Deployment**: Multi-node pool Kubernetes cluster
- **Container Insights**: Comprehensive container monitoring
- **Prometheus Integration**: Custom metrics collection
- **Multi-Platform Support**: Linux and Windows containers
- **Pod-Level Monitoring**: Container resource tracking
- **Custom Alerting**: Pod down notifications
- **Dashboard Creation**: Real-time cluster visualization
- **Workbook Development**: Interactive cluster analysis
- **RBAC Management**: Dashboard sharing and permissions

## Table of Contents

- [Lab Objectives](#lab-objectives)
- [Architecture](#architecture)
- [Task Breakdown](#task-breakdown)
- [AKS Configuration](#aks-configuration)
- [Container Insights Setup](#container-insights-setup)
- [Application Deployment](#application-deployment)
- [Alert Rules](#alert-rules)
- [Dashboard Components](#dashboard-components)
- [Workbook Features](#workbook-features)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Repository Structure](#repository-structure)
- [Screenshots](#screenshots)
- [Validation](#validation)
- [Credits](#credits)

## Lab Objectives

### Primary Goals
- **Deploy AKS cluster** with Linux and Windows node pools
- **Enable Container Insights** for comprehensive monitoring
- **Deploy applications** on both node pool types
- **Configure Prometheus metrics** collection
- **Create alert rules** for pod availability
- **Build custom dashboards** with 8+ metrics
- **Develop workbooks** for cluster analysis
- **Share dashboards** with appropriate RBAC

### Learning Outcomes
- AKS cluster architecture and deployment
- Container Insights configuration
- Prometheus metrics integration
- Kubernetes manifest deployment
- kubectl command-line operations
- KQL queries for container logs
- Cluster performance monitoring
- Multi-platform container orchestration
- Dashboard sharing and permissions

## Architecture

### AKS Cluster Architecture

```
Azure Kubernetes Service (AKS)
    ↓
┌────────────────────────────────────────┐
│  Control Plane (Managed by Azure)     │
│  - API Server                          │
│  - Scheduler                           │
│  - Controller Manager                  │
│  - etcd                                │
└────────────────────────────────────────┘
    ↓
┌────────────────────────────────────────┐
│  Node Pools                            │
│  ├─ Linux Node Pool                    │
│  │  ├─ Node 1 (Standard_DS2_v2)        │
│  │  ├─ Node 2                          │
│  │  └─ Node 3                          │
│  └─ Windows Node Pool                  │
│     ├─ Node 1 (Standard_DS2_v2)        │
│     └─ Node 2                          │
└────────────────────────────────────────┘
```

### Container Insights Architecture

```
AKS Cluster
    ↓
Container Insights Agent (DaemonSet)
    ↓
┌────────────────────────────────────────┐
│  Data Collection                       │
│  ├─ Container logs                     │
│  ├─ Performance metrics                │
│  ├─ Node metrics                       │
│  ├─ Pod metrics                        │
│  └─ Prometheus metrics                 │
└────────────────────────────────────────┘
    ↓
Log Analytics Workspace
    ↓
┌────────────────────────────────────────┐
│  Azure Monitor                         │
│  ├─ Container Insights                 │
│  ├─ Metrics Explorer                   │
│  ├─ Logs (KQL queries)                 │
│  └─ Alerts                             │
└────────────────────────────────────────┘
```

### Monitoring Flow

```
Kubernetes Workloads
    ↓
Container Insights Agent
    ↓
Metrics & Logs Collection
    ↓
┌────────────────────────────────────────┐
│  Monitoring Data                       │
│  ├─ CPU usage per container            │
│  ├─ Memory usage per container         │
│  ├─ Network I/O                        │
│  ├─ Disk I/O                           │
│  ├─ Pod restarts                       │
│  └─ Container states                   │
└────────────────────────────────────────┘
    ↓
┌────────────────────────────────────────┐
│  Alerts                                │
│  └─ Pods Down Alert                    │
└────────────────────────────────────────┘
    ↓
Email Notifications
```

## Task Breakdown

### Task 1: Creating Azure Resources

**Requirements**:
✅ Create AKS cluster with Linux and Windows node pools
✅ Copy manifest files to Azure Cloud Shell
✅ Configure kubectl to connect to cluster
✅ Deploy applications using kubectl apply
✅ Monitor deployment progress
✅ Verify external IP assignment

#### 1.1 AKS Cluster Creation

**Linux Node Pool Configuration**:
```hcl
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = "1.27.0"
  
  default_node_pool {
    name                = "linuxpool"
    node_count          = 3
    vm_size             = "Standard_DS2_v2"
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }
  
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
}
```

**Windows Node Pool Configuration**:
```hcl
resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  name                  = "winpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size              = "Standard_DS2_v2"
  node_count           = 2
  os_type              = "Windows"
  os_disk_size_gb      = 128
  enable_auto_scaling  = true
  min_count            = 1
  max_count            = 3
  
  node_labels = {
    "kubernetes.io/os" = "windows"
  }
}
```

**Cluster Specifications**:
- **Linux Pool**: 3 nodes, auto-scaling (2-5 nodes)
- **Windows Pool**: 2 nodes, auto-scaling (1-3 nodes)
- **VM Size**: Standard_DS2_v2 (2 vCPU, 7 GB RAM)
- **Network Plugin**: Azure CNI
- **Container Insights**: Enabled at creation

#### 1.2 Application Deployment

**Linux Application Manifest** (`linux_container.yaml`):
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: linux-app

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: linux-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: linux-app
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

**Windows Application Manifest** (`windows_container.yaml`):
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: windows-app

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: iis-deployment
  namespace: windows-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: iis
  template:
    metadata:
      labels:
        app: iis
    spec:
      nodeSelector:
        kubernetes.io/os: windows
      containers:
      - name: iis
        image: mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2022
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi

---
apiVersion: v1
kind: Service
metadata:
  name: iis-service
  namespace: windows-app
spec:
  type: LoadBalancer
  selector:
    app: iis
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

**Deployment Commands**:
```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group rg-aks-monitoring \
  --name aks-cluster

# Deploy Linux application
kubectl apply -f linux_container.yaml

# Deploy Windows application
kubectl apply -f windows_container.yaml

# Monitor deployment
kubectl get pods -n linux-app --watch
kubectl get pods -n windows-app --watch

# Check services
kubectl get service -n linux-app --watch
kubectl get service -n windows-app --watch

# Wait for external IP
# CTRL-C when IP is assigned
```

**Expected Output**:
```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5d59d67564-abc12   1/1     Running   0          2m
nginx-deployment-5d59d67564-def34   1/1     Running   0          2m
nginx-deployment-5d59d67564-ghi56   1/1     Running   0          2m

NAME            TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
nginx-service   LoadBalancer   10.0.123.45    20.12.34.56      80:30080/TCP   3m
```

### Task 2: Enable Container Insights

**Requirements**:
✅ Enable Container Insights
✅ Update Container Insights to enable metrics (Prometheus)

#### 2.1 Enable Container Insights

**During Cluster Creation** (Terraform):
```hcl
resource "azurerm_kubernetes_cluster" "aks" {
  # ... other configuration ...
  
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
  
  azure_policy_enabled = true
}
```

**For Existing Cluster** (Azure CLI):
```bash
# Enable Container Insights
az aks enable-addons \
  --resource-group rg-aks-monitoring \
  --name aks-cluster \
  --addons monitoring \
  --workspace-resource-id /subscriptions/.../workspaces/...

# Verify addon status
az aks show \
  --resource-group rg-aks-monitoring \
  --name aks-cluster \
  --query addonProfiles.omsagent
```

**What Gets Installed**:
- OMS Agent DaemonSet on every node
- ConfigMap for Container Insights configuration
- Service account with cluster-reader permissions
- Data collection rules

#### 2.2 Enable Prometheus Metrics

**Configuration Steps**:

1. **Create ConfigMap** for Prometheus scraping:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: container-azm-ms-agentconfig
  namespace: kube-system
data:
  schema-version: v1
  config-version: ver1
  
  prometheus-data-collection-settings: |-
    [prometheus_data_collection_settings.cluster]
        interval = "1m"
        fieldpass = ["container_.*", "kube_.*"]
        
    [prometheus_data_collection_settings.node]
        interval = "1m"
        fieldpass = ["node_.*"]
```

2. **Apply Configuration**:
```bash
kubectl apply -f container-insights-prometheus.yaml
```

3. **Verify Prometheus Metrics**:
```bash
# Check if metrics are being collected
kubectl logs -n kube-system -l component=oms-agent -c oms-agent --tail=100
```

**Terraform Resource**:
```hcl
resource "azurerm_monitor_data_collection_rule" "aks_prometheus" {
  name                = "MSCI-${var.cluster_name}-prometheus"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = "ciworkspace"
    }
  }
  
  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["ciworkspace"]
  }
  
  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }
}
```

**Prometheus Metrics Collected**:
- `container_cpu_usage_seconds_total`
- `container_memory_working_set_bytes`
- `kube_pod_status_phase`
- `kube_pod_container_status_restarts_total`
- `node_cpu_seconds_total`
- `node_memory_MemAvailable_bytes`

### Task 3: Alerting and Visualization

**Requirements**:
✅ Create alert when AKS pods are down
✅ Create dashboard with 8 metrics
✅ Create workbook with 2+ metric charts and 2+ log charts

#### 3.1 Pod Down Alert

**Alert Configuration**:

**KQL Query**:
```kql
let podDownThreshold = 1;
KubePodInventory
| where TimeGenerated > ago(5m)
| where PodStatus in ("Failed", "Unknown", "Pending")
| summarize PodCount = dcount(PodUid) by Computer, ClusterName, Namespace
| where PodCount >= podDownThreshold
```

**Alert Rule Settings**:
- **Name**: `AKS Pods Down Alert`
- **Frequency**: Every 5 minutes
- **Time range**: Last 5 minutes
- **Threshold**: 0 results (fires when pods are down)
- **Severity**: Sev 1 (Critical)
- **Action Group**: Email notification

**Terraform Resource**:
```hcl
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "pods_down" {
  name                = "aks-pods-down-alert"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes              = [var.log_analytics_workspace_id]
  severity            = 1
  
  criteria {
    query = <<-QUERY
      KubePodInventory
      | where TimeGenerated > ago(5m)
      | where PodStatus in ("Failed", "Unknown", "Pending")
      | summarize PodCount = dcount(PodUid) by Computer, ClusterName, Namespace
      | where PodCount >= 1
    QUERY
    
    threshold = 0
    operator  = "GreaterThanOrEqual"
    
    metric_measure_column = "PodCount"
    
    dimension {
      name     = "Computer"
      operator = "Include"
      values   = ["*"]
    }
    
    dimension {
      name     = "Namespace"
      operator = "Include"
      values   = ["*"]
    }
  }
  
  action {
    action_groups = [var.action_group_id]
  }
  
  description = "Alert when pods are in Failed, Unknown, or Pending state"
}
```

**Additional Alert Variations**:

**High Pod Restart Count**:
```kql
KubePodInventory
| where TimeGenerated > ago(1h)
| extend RestartCount = toint(PodRestartCount)
| where RestartCount > 5
| summarize TotalRestarts = sum(RestartCount) by PodName, Namespace
```

**Node Not Ready**:
```kql
KubeNodeInventory
| where TimeGenerated > ago(5m)
| where Status != "Ready"
| distinct Computer, Status
```

#### 3.2 Dashboard Configuration

**Required Components (8 metrics)**:

1. **Node Status**
   - Type: Donut chart
   - KQL Query:
   ```kql
   KubeNodeInventory
   | where TimeGenerated > ago(5m)
   | summarize Count = dcount(Computer) by Status
   ```

2. **Pod/Container Status**
   - Type: Bar chart
   - KQL Query:
   ```kql
   KubePodInventory
   | where TimeGenerated > ago(5m)
   | summarize Count = dcount(PodUid) by PodStatus
   ```

3. **Available Memory in Cluster**
   - Type: Line chart
   - KQL Query:
   ```kql
   Perf
   | where TimeGenerated > ago(1h)
   | where ObjectName == "K8SNode"
   | where CounterName == "memoryAvailableBytes"
   | summarize AvailableMemoryMB = avg(CounterValue) / 1024 / 1024 by bin(TimeGenerated, 5m)
   | render timechart
   ```

4. **Total CPU in Cluster**
   - Type: Line chart
   - KQL Query:
   ```kql
   Perf
   | where TimeGenerated > ago(1h)
   | where ObjectName == "K8SNode"
   | where CounterName == "cpuUsageNanoCores"
   | summarize TotalCPU = sum(CounterValue) / 1000000000 by bin(TimeGenerated, 5m)
   | render timechart
   ```

5. **Nodes CPU Usage**
   - Type: Multi-line chart
   - KQL Query:
   ```kql
   Perf
   | where TimeGenerated > ago(1h)
   | where ObjectName == "K8SNode"
   | where CounterName == "cpuUsagePercentage"
   | summarize AvgCPU = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
   | render timechart
   ```

6. **Nodes Memory in %**
   - Type: Multi-line chart
   - KQL Query:
   ```kql
   Perf
   | where TimeGenerated > ago(1h)
   | where ObjectName == "K8SNode"
   | where CounterName == "memoryWorkingSetPercentage"
   | summarize AvgMemory = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
   | render timechart
   ```

7. **Nodes Count**
   - Type: Number tile
   - KQL Query:
   ```kql
   KubeNodeInventory
   | where TimeGenerated > ago(5m)
   | summarize NodeCount = dcount(Computer)
   ```

8. **Pods Count**
   - Type: Number tile
   - KQL Query:
   ```kql
   KubePodInventory
   | where TimeGenerated > ago(5m)
   | summarize PodCount = dcount(PodUid)
   ```

**Terraform Dashboard Resource**:
```hcl
resource "azurerm_portal_dashboard" "aks" {
  name                = "aks-monitoring-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = { x = 0, y = 0, colSpan = 4, rowSpan = 3 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              settings = {
                content = {
                  chartType = "Donut"
                  title     = "Node Status"
                }
              }
            }
          }
          // ... additional parts for each metric
        }
      }
    }
  })
}
```

#### 3.3 Workbook Configuration

**Minimum Requirements**: 2 metric charts + 2 log charts

**Metric Chart 1: Cluster Resource Utilization**
- **Data Source**: Azure Monitor Metrics
- **Metrics**:
  - Node CPU usage percentage
  - Node memory usage percentage
- **Visualization**: Multi-line chart
- **Time range**: Last 24 hours
- **Split by**: Node name

**Metric Chart 2: Pod Resource Consumption**
- **Data Source**: Azure Monitor Metrics via Prometheus
- **Metrics**:
  - Container CPU usage
  - Container memory working set
- **Visualization**: Stacked area chart
- **Time range**: Last 12 hours
- **Split by**: Namespace

**Log Query Chart 1: Pod Status Distribution**
```kql
KubePodInventory
| where TimeGenerated > ago(24h)
| summarize Count = dcount(PodUid) by PodStatus, bin(TimeGenerated, 1h)
| render areachart
```
- **Visualization**: Stacked area chart
- **Purpose**: Track pod state changes over time

**Log Query Chart 2: Top Resource-Consuming Pods**
```kql
Perf
| where TimeGenerated > ago(1h)
| where ObjectName == "K8SContainer"
| where CounterName == "cpuUsageNanoCores"
| summarize AvgCPU = avg(CounterValue) by InstanceName
| top 10 by AvgCPU desc
| render barchart
```
- **Visualization**: Bar chart
- **Purpose**: Identify resource-intensive workloads

**Log Query Chart 3: Container Restarts**
```kql
KubePodInventory
| where TimeGenerated > ago(7d)
| where PodRestartCount > 0
| summarize TotalRestarts = sum(toint(PodRestartCount)) by PodName, Namespace, bin(TimeGenerated, 1d)
| render columnchart
```
- **Visualization**: Column chart
- **Purpose**: Track container stability

**Log Query Chart 4: Network Traffic by Namespace**
```kql
InsightsMetrics
| where TimeGenerated > ago(24h)
| where Name == "kube_pod_network_bytes_total"
| summarize NetworkBytes = sum(Val) by Namespace, bin(TimeGenerated, 1h)
| render timechart
```
- **Visualization**: Time chart
- **Purpose**: Monitor network activity

**Workbook Parameters**:
- Cluster selector (if multiple clusters)
- Time range picker
- Namespace filter
- Node filter
- Pod name search

## AKS Configuration

### Node Pool Details

**Linux Node Pool**:
- **OS**: Ubuntu 22.04
- **Container Runtime**: containerd
- **Nodes**: 3 (auto-scale 2-5)
- **VM Size**: Standard_DS2_v2
- **Disk**: 30 GB OS disk
- **Role**: General workloads, system pods

**Windows Node Pool**:
- **OS**: Windows Server 2022
- **Container Runtime**: Docker
- **Nodes**: 2 (auto-scale 1-3)
- **VM Size**: Standard_DS2_v2
- **Disk**: 128 GB OS disk (Windows requirement)
- **Role**: Windows-specific workloads

### Network Configuration

**Network Plugin**: Azure CNI
- Direct pod IP addresses from VNet
- Better performance than kubenet
- Required for Windows node pools

**Network Policy**: Azure Network Policy
- Pod-to-pod traffic control
- Namespace isolation
- Ingress/egress rules

**Service CIDR**: 10.0.0.0/16
**DNS Service IP**: 10.0.0.10
**Pod CIDR**: Not applicable (Azure CNI)

### Resource Limits

**Per Pod**:
```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 250m
    memory: 256Mi
```

**Cluster Quotas**:
- Maximum pods per node: 30 (Azure CNI default)
- Maximum nodes: Subscription limit
- Total cores: Based on VM size * node count

## Container Insights Setup

### Agent Configuration

**OMS Agent DaemonSet**:
- Deployed automatically on all nodes
- Collects logs from `/var/log/containers/`
- Scrapes kubelet metrics
- Forwards data to Log Analytics

**Data Collection Interval**:
- Performance metrics: Every 60 seconds
- Inventory data: Every 5 minutes
- Logs: Real-time streaming

### Collected Data Types

**Performance Metrics**:
```
- CPU usage (node, pod, container)
- Memory usage (node, pod, container)
- Network I/O (bytes sent/received)
- Disk I/O (reads/writes)
- File system usage
```

**Inventory Data**:
```
- Node inventory (KubeNodeInventory)
- Pod inventory (KubePodInventory)
- Container inventory (ContainerInventory)
- Service inventory (KubeServices)
```

**Logs**:
```
- Container logs (ContainerLog)
- Kubernetes events (KubeEvents)
- Node logs (Syslog)
```

**Prometheus Metrics** (when enabled):
```
- Custom application metrics
- Service mesh metrics
- Additional Kubernetes metrics
```

## Application Deployment

### Linux Application (Nginx)

**Deployment Strategy**:
- 3 replicas for high availability
- Node selector for Linux nodes
- Resource requests and limits defined
- LoadBalancer service for external access

**Features**:
- Rolling updates
- Readiness/liveness probes (if configured)
- Auto-scaling (HPA can be added)
- Multi-zone distribution

### Windows Application (IIS)

**Deployment Strategy**:
- 2 replicas
- Node selector for Windows nodes
- Higher resource allocation (Windows overhead)
- LoadBalancer service

**Considerations**:
- Larger image size (~5GB for Windows base)
- Longer pull and startup times
- Higher memory requirements
- Different logging mechanisms

### Deployment Verification

```bash
# Check all pods
kubectl get pods --all-namespaces

# Describe pod for details
kubectl describe pod <pod-name> -n <namespace>

# Check pod logs
kubectl logs <pod-name> -n <namespace>

# Get service external IP
kubectl get svc -n linux-app
kubectl get svc -n windows-app

# Test application
curl http://<external-ip>
```

## Alert Rules

### Alert Summary

| Alert Name | Type | Condition | Threshold | Frequency | Severity |
|------------|------|-----------|-----------|-----------|----------|
| Pods Down | Log (KQL) | Pod status Failed/Unknown/Pending | >= 1 pod | 5 min | Sev 1 |
| High Pod Restarts | Log (KQL) | Restart count | > 5 | 1 hour | Sev 2 |
| Node Not Ready | Log (KQL) | Node status != Ready | Any node | 5 min | Sev 1 |
| High CPU Usage | Metric | Node CPU % | > 80% | 5 min | Sev 2 |
| High Memory Usage | Metric | Node Memory % | > 85% | 5 min | Sev 2 |

### Action Group Configuration

```hcl
resource "azurerm_monitor_action_group" "aks_alerts" {
  name                = "aks-alert-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "aksalert"
  
  email_receiver {
    name          = "admin"
    email_address = var.admin_email
  }
  
  email_receiver {
    name          = "devops"
    email_address = var.devops_email
  }
  
  webhook_receiver {
    name        = "teams-webhook"
    service_uri = var.teams_webhook_url
  }
}
```

## Dashboard Components

### Dashboard Layout

**Top Row**: Cluster Health Overview
- Node Status (donut chart)
- Nodes Count (number)
- Pods Count (number)
- Pod/Container Status (bar chart)

**Middle Row**: Resource Utilization
- Total CPU in Cluster (line chart)
- Available Memory in Cluster (line chart)
- Nodes CPU Usage (multi-line chart)
- Nodes Memory % (multi-line chart)

**Bottom Row**: Additional Metrics
- Network traffic
- Disk usage
- Container restarts
- Failed pods

### Dashboard Sharing

**RBAC Configuration**:
```hcl
resource "azurerm_role_assignment" "dashboard_reader" {
  scope                = azurerm_portal_dashboard.aks.id
  role_definition_name = "Reader"
  principal_id         = var.trainer_principal_id
}

resource "azurerm_role_assignment" "contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = var.trainer_principal_id
}
```

**Sharing Steps**:
1. Navigate to Azure Portal → Dashboards
2. Select "aks-monitoring-dashboard"
3. Click "Share" button
4. Choose sharing scope (Subscription/Resource Group)
5. Grant Contributor access to trainer email
6. Save changes

## Workbook Features

### Interactive Analysis

**Parameters for Dynamic Filtering**:
- **Cluster**: Dropdown selector for multi-cluster environments
- **Time Range**: Last 1h, 6h, 24h, 7d, 30d, custom
- **Namespace**: Multi-select dropdown
- **Node Pool**: Linux, Windows, or both
- **Pod Name**: Search box with autocomplete

### Advanced Visualizations

**Resource Heatmaps**:
- CPU usage across all nodes
- Memory usage by namespace
- Pod distribution by node

**Trend Analysis**:
- Historical resource consumption
- Growth projections
- Capacity planning insights

**Correlation Views**:
- CPU vs Memory usage
- Network I/O vs application load
- Pod restarts vs resource constraints

## Key Features

### Multi-Platform Support
- **Linux containers**: Nginx, standard workloads
- **Windows containers**: IIS, .NET Framework applications
- **Mixed workloads**: Single cluster management
- **Unified monitoring**: Consistent observability

### Comprehensive Monitoring
- **Node-level metrics**: CPU, memory, disk, network
- **Pod-level metrics**: Resource consumption, status
- **Container metrics**: Individual container tracking
- **Prometheus integration**: Custom metrics support

### Intelligent Alerting
- **Proactive alerts**: Detect issues before impact
- **Multi-condition rules**: Complex alert logic
- **Customizable thresholds**: Environment-specific tuning
- **Action groups**: Multiple notification channels

### Rich Visualizations
- **Real-time dashboards**: Live cluster status
- **Interactive workbooks**: Ad-hoc analysis
- **Custom queries**: KQL-powered insights
- **Sharing capabilities**: Team collaboration

## Prerequisites

### Required Tools
- **Terraform**: >= 1.0.0
- **Azure CLI**: Latest version
- **kubectl**: Kubernetes command-line tool
- **Azure Subscription**: Active with AKS quota

### Required Permissions
- **Subscription Contributor**: Resource creation
- **User Access Administrator**: RBAC assignments
- **AKS Cluster Admin**: Cluster operations

### Required Knowledge
- Kubernetes fundamentals
- Container concepts
- Azure Monitor basics
- KQL query language
- YAML syntax

## Getting Started

### Step 1: Provision AKS Cluster

```bash
# Clone repository
git clone <repository-url>
cd azure-monitor-lab3

# Configure Azure authentication
az login
az account set --subscription "your-subscription-id"

# Create terraform.tfvars
cat > terraform.tfvars <<EOF
resource_group_name        = "rg-aks-monitoring"
location                   = "eastus"
cluster_name               = "aks-cluster"
dns_prefix                 = "aks-mon"
log_analytics_workspace_id = "/subscriptions/.../workspaces/..."
admin_email                = "admin@example.com"
trainer_email              = "trainer@example.com"
EOF

# Deploy infrastructure
terraform init
terraform plan
terraform apply
```

### Step 2: Configure kubectl

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group rg-aks-monitoring \
  --name aks-cluster \
  --overwrite-existing

# Verify connection
kubectl get nodes
kubectl cluster-info

# Check node pools
kubectl get nodes --show-labels | grep "kubernetes.io/os"
```

### Step 3: Deploy Applications

```bash
# Deploy Linux application
kubectl apply -f linux_container.yaml

# Deploy Windows application
kubectl apply -f windows_container.yaml

# Monitor deployments
kubectl get pods -n linux-app --watch
kubectl get pods -n windows-app --watch

# Wait for services to get external IPs
kubectl get svc -n linux-app --watch
kubectl get svc -n windows-app --watch
```

### Step 4: Verify Container Insights

```bash
# Check if Container Insights is enabled
az aks show \
  --resource-group rg-aks-monitoring \
  --name aks-cluster \
  --query addonProfiles.omsagent

# Verify agent pods
kubectl get pods -n kube-system | grep oms-agent

# Check agent logs
kubectl logs -n kube-system -l component=oms-agent -c oms-agent --tail=50
```

### Step 5: Test Applications

```bash
# Get service external IPs
LINUX_IP=$(kubectl get svc -n linux-app nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
WINDOWS_IP=$(kubectl get svc -n windows-app iis-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test Linux application
curl http://$LINUX_IP

# Test Windows application
curl http://$WINDOWS_IP
```

## Repository Structure

```
.
├── modules/
│   ├── aks/                           # AKS cluster module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alerts/                        # Alert rules
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── dashboard/                     # Custom dashboard
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── workbook/                      # Custom workbook
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── rbac/                          # Role assignments
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── linux_container.yaml               # Linux app manifest
├── windows_container.yaml             # Windows app manifest
├── main.tf                            # Root module
├── variables.tf                       # Input variables
├── providers.tf                       # Provider configuration
├── LIMITATIONS.md                     # Known limitations
└── README.md                         # This file
```

## Screenshots

### Dashboard Screenshot

![AKS Monitoring Dashboard]()
*Custom dashboard showing node status, pod count, CPU/memory metrics, and cluster health*

### Workbook Screenshot

![AKS Workbook]()
*Interactive workbook with metric charts and log query visualizations for cluster analysis*

### Alert Email Screenshots

![Alert Email - Pods Down]()
*Email notification when pods enter Failed, Unknown, or Pending state*

![Alert Email - Node Not Ready]()
*Email notification when cluster nodes become unavailable*

> **Note**: Add your screenshots showing:
> 1. Complete dashboard with all 8 metrics
> 2. Workbook with minimum 2 metric + 2 log charts
> 3. Email notifications from triggered alerts
> 4. Container Insights overview showing cluster data

## Validation

### Cluster Validation

```bash
# Check cluster status
az aks show \
  --resource-group rg-aks-monitoring \
  --name aks-cluster \
  --query provisioningState

# List node pools
az aks nodepool list \
  --resource-group rg-aks-monitoring \
  --cluster-name aks-cluster \
  --output table

# Check nodes
kubectl get nodes -o wide

# Verify node pools
kubectl get nodes --show-labels | grep "kubernetes.io/os"
```

### Application Validation

```bash
# Check deployments
kubectl get deployments --all-namespaces

# Check pods
kubectl get pods --all-namespaces

# Check services
kubectl get svc --all-namespaces

# Test applications
LINUX_IP=$(kubectl get svc -n linux-app nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$LINUX_IP
```

### Container Insights Validation

```bash
# Query container logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "ContainerLog | take 10"

# Query pod inventory
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "KubePodInventory | summarize count() by PodStatus"

# Query node inventory
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "KubeNodeInventory | distinct Computer, Status"
```

### Alert Testing

```bash
# Create a failing pod to trigger alert
kubectl run failing-pod --image=invalid-image-name -n linux-app

# Check pod status
kubectl get pods -n linux-app

# Wait for alert (5 minutes)
# Check email for notification

# Delete test pod
kubectl delete pod failing-pod -n linux-app
```

## Contributing

This repository documents personal learning progress through a DevOps bootcamp. While it's primarily for educational purposes, suggestions and improvements are welcome!

### How to Contribute

1. **Report Issues**: Found a bug or error in scripts?
   - Open an issue describing the problem
   - Include script name and error message
   - Provide steps to reproduce

2. **Suggest Improvements**: Have ideas for better implementations?
   - Fork the repository
   - Create a feature branch
   - Submit pull request with clear description

3. **Share Knowledge**: Learned something new?
   - Add comments or documentation
   - Create additional practice exercises
   - Write tutorials or guides

## License

This project is created for educational purposes as part of a DevOps bootcamp internship.

**Educational Use**: Feel free to use these scripts and documentation for learning purposes.

**Attribution**: If you use or reference this work, please provide attribution to the original author.

**No Warranty**: These scripts are provided "as is" without warranty of any kind. Use at your own risk, especially in production environments.
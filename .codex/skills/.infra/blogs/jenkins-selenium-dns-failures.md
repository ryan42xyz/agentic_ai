# Issue Type: Jenkins

## Problem Pattern
- Category: Selenium Test Failures
- Symptoms: 
  - DNS resolution errors (`net::ERR_NAME_NOT_RESOLVED`)
  - API endpoint connection failures
  - Tests failing with network connectivity errors
- Alert Pattern: Jenkins build marked as unstable or failed

## Standard Investigation Process

### 1. Initial Assessment
- Commands to run:
  ```bash
  # Check DNS resolution from Jenkins agent
  ssh jenkins-agent
  nslookup <target-hostname>
  ping -c 4 <target-hostname>
  
  # Check network connectivity
  traceroute <target-hostname>
  curl -v <api-endpoint-url>
  
  # Check Kubernetes resources (if applicable)
  ${CLUSTER_ALIAS} get pods -n <namespace>
  ${CLUSTER_ALIAS} get svc -n <namespace>
  ${CLUSTER_ALIAS} get ingress -n <namespace>
  ```
- What to look for:
  - DNS resolution failures
  - Network connectivity issues
  - Missing or misconfigured Kubernetes services
  - Ingress controller issues

### 2. Common Causes
- **DNS Configuration Issues**: 
  - Incorrect or missing DNS entries
  - DNS server unavailability
  - `/etc/hosts` file misconfiguration
  
- **Network Connectivity Problems**:
  - Firewall blocking connections
  - VPN issues
  - Network segmentation preventing access
  
- **Service Availability**:
  - Test environment not deployed
  - Services not running or crashed
  - Incorrect service configuration
  
- **Application Issues**:
  - API endpoints not implemented
  - Application errors
  - Database connectivity problems

### 3. Resolution Steps
- **For DNS Issues**:
  1. Update `/etc/hosts` file with correct entries
  2. Configure proper DNS resolution
  3. Verify DNS server is accessible
  
- **For Network Issues**:
  1. Check firewall rules
  2. Verify network routes
  3. Ensure VPN is configured correctly if needed
  
- **For Service Issues**:
  1. Deploy or restart required services
  2. Check service logs for errors
  3. Verify service configuration
  
- **For Application Issues**:
  1. Check application logs
  2. Verify API endpoints are implemented
  3. Check database connectivity

### 4. Prevention
- **Long-term fixes**:
  - Implement health checks for test environments
  - Add DNS resolution checks before test execution
  - Create more resilient test infrastructure
  - Implement retry mechanisms in tests
  
- **Monitoring improvements**:
  - Monitor test environment availability
  - Set up alerts for repeated test failures
  - Create dashboards for test environment health

## Example Case
- Reference: JENKINS_18988
- Specific Commands Used:
  ```bash
  # Check DNS resolution
  nslookup admin-demo2.dv-api.com
  
  # Check Kubernetes resources
  kwestproda get pods -n qaautotest
  kwestproda get svc -n qaautotest
  
  # Check database connection
  kwestproda exec -it mysql-pod -n database -- mysql -e "SHOW DATABASES LIKE 'datavisor_prod_ui';"
  ```
- Resolution Summary:
  The issue was caused by DNS resolution failures in the Jenkins agent environment. The agent could not resolve the hostname for the test application, resulting in Selenium test failures. The problem was fixed by updating the DNS configuration in the Jenkins agent and ensuring the test environment was properly deployed. 
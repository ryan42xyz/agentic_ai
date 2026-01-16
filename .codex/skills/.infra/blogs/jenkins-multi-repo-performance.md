# Issue Type: Jenkins Performance
## Problem Pattern
- Category: Multi-Repository Code Landing Jobs
- Symptoms: 
  * Excessively long build times (3+ hours)
  * High resource consumption (28Gi memory, 5000m CPU)
  * Multiple repository checkouts
  * Multiple revision processing
- Alert Pattern: Jenkins build durations > 2 hours

## Standard Investigation Process
1. Initial Assessment
   - Check build information:
     ```bash
     ./oncall.sh jenkins --env old --job <job_name> --build <build_number>
     ```
   - Review console output for timing patterns:
     ```bash
     ./oncall.sh jenkins --env old --job <job_name> --build <build_number> --console
     ```
   - Extract key operation timestamps:
     ```bash
     grep -E "^\[.*\]" <console_log_file> > timestamps.txt
     ```

2. Common Causes
   - **Multiple Repository Operations**: Sequential checkout and processing of multiple Git repositories
   - **Arc Land Operations**: Slow Phabricator integration for landing code
   - **Complex JIRA Integration**: Multiple API calls and data processing
   - **Multiple Revision Processing**: Sequential processing of dependent revisions
   - **Resource Constraints**: Insufficient memory or CPU allocation for parallel operations

3. Resolution Steps
   - Pipeline Optimization:
     * Implement parallel repository operations
     * Use incremental checkouts where possible
     * Split multi-revision landing into separate jobs
   - Resource Optimization:
     * Review memory and CPU requirements
     * Consider dedicated node pools for resource-intensive jobs
   - Integration Optimization:
     * Batch API calls to external systems
     * Implement efficient caching strategies
     * Use asynchronous operations where possible

4. Prevention
   - Implement build time monitoring and alerts
   - Create guidelines for efficient multi-repository operations
   - Optimize Jenkinsfile for parallel execution
   - Implement repository caching
   - Review resource allocation periodically

## Example Case
- Reference: JENKINS_29879
- Specific Commands Used:
  ```bash
  # Get build information
  ./oncall.sh jenkins --env old --job land-code-multiple-repo --build 29879
  
  # Analyze console output
  ./oncall.sh jenkins --env old --job land-code-multiple-repo --build 29879 --console
  
  # Extract key operations
  grep -i "git" console.log > git_operations.txt
  grep -i "arc" console.log > arc_operations.txt
  grep -i "jira" console.log > jira_operations.txt
  ```
- Resolution Summary:
  The job "land-code-multiple-repo/29879" took approximately 3.5 hours to complete due to processing multiple code revisions (D44471, D44717, D45613, D45739) related to the development of an AI-generated feature descriptions feature (CRE-5623). The primary bottlenecks were:
  1. Sequential processing of multiple repositories
  2. Complex integration with Phabricator for code landing
  3. Multiple JIRA API calls for status updates
  4. Extended development timeline requiring complex merge operations
  
  Recommendations included pipeline optimization for parallel execution, resource allocation review, and integration optimization to reduce API call overhead.

## Performance Benchmarks
- Typical land-code-multiple-repo job: 30-60 minutes
- Slow job threshold: > 120 minutes
- Critical performance issue: > 180 minutes

## Optimization Metrics
- Target performance improvement: 60-80% reduction in build time
- Resource utilization target: 50% reduction in CPU-hours and memory-hours
- Developer feedback cycle target: < 60 minutes for code landing confirmation 
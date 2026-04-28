#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <namespace> <cluster-name>"
    echo "Example: $0 pg-0 db17-0"
    exit 1
fi

NAMESPACE=$1
CLUSTER_NAME=$2

# Find the primary pod
echo -e "${BLUE}=== Finding Primary Pod ===${NC}"
PRIMARY_POD=$(kubectl get pods -n $NAMESPACE -l cnpg.io/cluster=$CLUSTER_NAME,role=primary -o jsonpath='{.items[0].metadata.name}')

if [ -z "$PRIMARY_POD" ]; then
    echo -e "${RED}Error: Could not find primary pod for cluster $CLUSTER_NAME in namespace $NAMESPACE${NC}"
    exit 1
fi

echo -e "Primary pod: ${GREEN}$PRIMARY_POD${NC}\n"

# Get current memory usage
echo -e "${BLUE}=== Current Pod Memory Usage ===${NC}"
CURRENT_USAGE=$(kubectl top pod $PRIMARY_POD -n $NAMESPACE 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "$CURRENT_USAGE"
else
    echo -e "${YELLOW}Warning: metrics-server not available, cannot show current usage${NC}"
fi
echo ""

# Get PostgreSQL settings
echo -e "${BLUE}=== PostgreSQL Memory Configuration ===${NC}"
PG_SETTINGS=$(kubectl exec -n $NAMESPACE $PRIMARY_POD -- psql -U postgres -t -A -F '|' -c "
SELECT name, setting, COALESCE(unit, 'count') as unit
FROM pg_settings 
WHERE name IN ('shared_buffers', 'work_mem', 'max_connections', 'maintenance_work_mem', 'wal_buffers', 'effective_cache_size')
ORDER BY name;
" 2>/dev/null)

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Could not retrieve PostgreSQL settings${NC}"
    exit 1
fi

# Parse settings
declare -A pg_config
while IFS='|' read -r name setting unit; do
    pg_config[$name]="$setting|$unit"
done <<< "$PG_SETTINGS"

# Function to convert to MB
convert_to_mb() {
    local value=$1
    local unit=$2
    
    case $unit in
        "8kB")
            echo $((value * 8 / 1024))
            ;;
        "kB")
            echo $((value / 1024))
            ;;
        "MB")
            echo $value
            ;;
        "GB")
            echo $((value * 1024))
            ;;
        *)
            echo 0
            ;;
    esac
}

# Extract and convert values
IFS='|' read -r shared_buffers_val shared_buffers_unit <<< "${pg_config[shared_buffers]}"
IFS='|' read -r work_mem_val work_mem_unit <<< "${pg_config[work_mem]}"
IFS='|' read -r maintenance_work_mem_val maintenance_work_mem_unit <<< "${pg_config[maintenance_work_mem]}"
IFS='|' read -r wal_buffers_val wal_buffers_unit <<< "${pg_config[wal_buffers]}"
IFS='|' read -r max_connections_val max_connections_unit <<< "${pg_config[max_connections]}"
IFS='|' read -r effective_cache_val effective_cache_unit <<< "${pg_config[effective_cache_size]}"

# Convert to MB
shared_buffers_mb=$(convert_to_mb $shared_buffers_val $shared_buffers_unit)
work_mem_mb=$(convert_to_mb $work_mem_val $work_mem_unit)
maintenance_work_mem_mb=$(convert_to_mb $maintenance_work_mem_val $maintenance_work_mem_unit)
wal_buffers_mb=$(convert_to_mb $wal_buffers_val $wal_buffers_unit)
effective_cache_mb=$(convert_to_mb $effective_cache_val $effective_cache_unit)

# Display settings
echo "shared_buffers:       ${shared_buffers_mb}MB (${shared_buffers_val} ${shared_buffers_unit})"
echo "work_mem:             ${work_mem_mb}MB (${work_mem_val} ${work_mem_unit})"
echo "maintenance_work_mem: ${maintenance_work_mem_mb}MB (${maintenance_work_mem_val} ${maintenance_work_mem_unit})"
echo "wal_buffers:          ${wal_buffers_mb}MB (${wal_buffers_val} ${wal_buffers_unit})"
echo "max_connections:      ${max_connections_val}"
echo "effective_cache_size: ${effective_cache_mb}MB (hint only, not allocated)"
echo ""

# Calculate memory requirements
echo -e "${BLUE}=== Memory Calculation ===${NC}"

# Connection overhead (conservative estimate: 2MB per connection)
connection_overhead=$((max_connections_val * 2))

# Base PostgreSQL memory
base_memory=$((shared_buffers_mb + maintenance_work_mem_mb + wal_buffers_mb + connection_overhead))

echo "Shared buffers:           ${shared_buffers_mb}MB"
echo "Maintenance work mem:     ${maintenance_work_mem_mb}MB"
echo "WAL buffers:              ${wal_buffers_mb}MB"
echo "Connection overhead:      ${connection_overhead}MB (${max_connections_val} × 2MB)"
echo "                          ────────"
echo "Base PostgreSQL memory:   ${base_memory}MB"
echo ""

# Add OS overhead
os_overhead=400
total_with_os=$((base_memory + os_overhead))
echo "OS/Container overhead:    ${os_overhead}MB"
echo "                          ────────"
echo "Total estimated usage:    ${total_with_os}MB"
echo ""

# Add safety margins
margin_20=$((total_with_os * 120 / 100))
margin_30=$((total_with_os * 130 / 100))
margin_50=$((total_with_os * 150 / 100))

echo -e "${YELLOW}=== Recommended Memory Limits ===${NC}"
echo "Conservative (20% margin): ${margin_20}MB (~$((margin_20 / 1024))Gi)"
echo "Balanced (30% margin):     ${margin_30}MB (~$((margin_30 / 1024))Gi)"
echo "Safe (50% margin):         ${margin_50}MB (~$((margin_50 / 1024))Gi)"
echo ""

# Determine recommended value (round up to nearest 512Mi)
recommended_mb=$margin_30
recommended_gi=$(( (recommended_mb + 511) / 512 ))
recommended_gi_half=$(( recommended_gi / 2 ))

if [ $((recommended_gi % 2)) -eq 0 ]; then
    recommended="${recommended_gi}Gi"
else
    recommended="${recommended_gi_half}.5Gi"
fi

# Get current pod limits
current_limits=$(kubectl get pod $PRIMARY_POD -n $NAMESPACE -o jsonpath='{.spec.containers[0].resources.limits.memory}')
current_requests=$(kubectl get pod $PRIMARY_POD -n $NAMESPACE -o jsonpath='{.spec.containers[0].resources.requests.memory}')
qos_class=$(kubectl get pod $PRIMARY_POD -n $NAMESPACE -o jsonpath='{.status.qosClass}')

echo -e "${BLUE}=== Current Pod Configuration ===${NC}"
echo "Memory Requests: ${current_requests:-Not Set}"
echo "Memory Limits:   ${current_limits:-Not Set}"
echo "QoS Class:       $qos_class"
echo ""

# Recommendation
echo -e "${GREEN}=== RECOMMENDATION ===${NC}"
echo -e "${GREEN}Set memory to: ${recommended}${NC}"
echo ""

# Generate YAML snippet
echo -e "${BLUE}=== YAML Configuration ===${NC}"
cat << YAML
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: $CLUSTER_NAME
  namespace: $NAMESPACE
spec:
  instances: 3
  
  resources:
    requests:
      memory: "$recommended"
      cpu: "1"
    limits:
      memory: "$recommended"  # Same as requests = Guaranteed QoS
      cpu: "1"
  
  # Optional: Optimize PostgreSQL settings
  postgresql:
    parameters:
      shared_buffers: "${shared_buffers_mb}MB"
      effective_cache_size: "$((recommended_mb * 75 / 100))MB"  # ~75% of pod memory
      maintenance_work_mem: "${maintenance_work_mem_mb}MB"
      work_mem: "${work_mem_mb}MB"
      max_connections: "${max_connections_val}"
  
  # Optional: Limit ephemeral storage
  ephemeralVolumesSizeLimit:
    shm: 512Mi
    temporaryData: 1Gi
YAML

echo ""
echo -e "${YELLOW}=== Next Steps ===${NC}"
echo "1. Monitor current usage: kubectl top pod $PRIMARY_POD -n $NAMESPACE"
echo "2. Check for OOM events: kubectl get events -n $NAMESPACE --field-selector involvedObject.name=$PRIMARY_POD | grep -i oom"
echo "3. Apply the configuration: kubectl edit cluster $CLUSTER_NAME -n $NAMESPACE"
echo "4. Monitor for a week and adjust if needed"
echo ""

# Check shared memory usage
echo -e "${BLUE}=== Shared Memory Usage ===${NC}"
kubectl exec -n $NAMESPACE $PRIMARY_POD -- df -h /dev/shm 2>/dev/null
echo ""


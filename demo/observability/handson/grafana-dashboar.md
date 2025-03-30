Open Grafana
Dashboard -> New Dashboard -> Add a new panel 
On Query -> Select Code 
add 
count(
  kube_pod_container_status_running{pod=~"important-pod.*"}
) - 
count(
  kube_pod_container_status_waiting_reason{reason=~"CrashLoopBackOff|Error", pod=~"important-pod.*"}
)

On Visualization 
  Type -> Stat
  Show Calulate 
  Panel Title Add

Add another panel
count(
  kube_pod_container_status_waiting_reason{reason=~"CrashLoopBackOff|Error", pod=~"important-pod.*"}
)


Loki Query Example {job=~".+"} |~ "(ERROR|FAILED)"

adding search box in dashboard.. 
setting 
variable

{job=~".+"} |~ "(?i)($search)" 


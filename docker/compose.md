# Compose file option order
 - NETWORKS
    1. Socket proxy
    2. Container internal
    3. Container newt
 - VOLUMES
    1. Whatever
 - SERVICES
    1. name
    2. image
    3. restart
    4. privileged
    5. security_opt
    6. cap_add
    7. read_only
    8. tmpfs
    9. user
    10. hostname
    11. networks
    12. ports
    13. volumes
    14. command
    15. environment
    16. labels
    17. healthcheck
    18. depends_on

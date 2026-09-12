# Compose file option order
 - NETWORKS
    1. Socket proxy
    2. Container internal
    3. Container newt
 - VOLUMES
    1. Whatever
 - LOCKDOWN
 - NAME
 - SERVICES
    1. container_name
    2. image
    3. restart
    4. privileged
    5. <<: *lockdown
    6. security_opt
    7. cap_add
    8. read_only
    9. tmpfs
    10. user
    11. hostname
    12. networks
    13. ports
    14. volumes
    13. environment
    15. command
    16. devices
    17. labels
    18. healthcheck
    19. depends_on
    20. deploy

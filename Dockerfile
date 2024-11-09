FROM kicad/kicad:nightly-202409

USER root

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

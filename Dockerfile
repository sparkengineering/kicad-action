FROM kicad/kicad:9.0.0-amd64

USER root

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

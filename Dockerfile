FROM kicad/kicad:nightly-202410

USER root

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

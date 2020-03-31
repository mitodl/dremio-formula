{% from "dremio/map.jinja" import dremio with context %}

include:
  - .service

dremio:
  pkg.installed:
    - pkgs: {{ dremio.pkgs }}
    - require_in:
        - service: dremio_service_running

{% from "dremio/map.jinja" import dremio with context %}

include:
  - .install
  - .service

dremio-config:
  file.managed:
    - name: {{ dremio.conf_file }}
    - source: salt://dremio/templates/conf.jinja
    - template: jinja
    - watch_in:
      - service: dremio_service_running
    - require:
      - pkg: dremio

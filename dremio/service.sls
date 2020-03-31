{% from "dremio/map.jinja" import dremio with context %}

dremio_service_running:
  service.running:
    - name: {{ dremio.service }}
    - enable: True

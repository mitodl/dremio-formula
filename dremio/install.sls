{% from "dremio/map.jinja" import dremio with context %}

include:
  - .service

create_dremio_user:
  user.present:
    - name: {{ dremio.user }}
    - shell: /bin/false
    - require_in:
        - service: dremio_service_running

install_dremio_dependencies:
  pkg.installed:
    - pkgs: {{ dremio.pkgs }}
    - require_in:
        - service: dremio_service_running

install_dremio_from_archive:
  archive.extracted:
    - name: /opt/dremio
    - source: {{ dremio.source }}
    - user: {{ dremio.user }}
    - group: {{ dremio.group }}
    - trim_output: True
    - skip_verify: True
    - enforce_toplevel: False
    - options: --strip-components=1
    - require_in:
        - service: dremio_service_running

create_dremio_log_directory:
  file.directory:
    - name: /var/log/dremio
    - user: {{ dremio.user }}
    - group: {{ dremio.group }}
    - recurse:
        - user
        - group

create_dremio_data_directory:
  file.directory:
    - name: {{ dremio.config.paths.local }}
    - user: {{ dremio.user }}
    - group: {{ dremio.group }}
    - makedirs: True
    - recurse:
        - user
        - group

create_service_definition:
  file.managed:
    - name: /etc/systemd/system/{{ dremio.service }}.service
    - source: salt://dremio/templates/dremio.service.j2
    - template: jinja
    - require_in:
        - service: dremio_service_running
    - require:
        - archive: install_dremio_from_archive
  cmd.wait:
    - name: systemctl daemon-reload
    - watch:
        - file: create_service_definition
    - require_in:
        - service: dremio_service_running

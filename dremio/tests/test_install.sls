{% from "dremio/map.jinja" import dremio with context %}

{% for pkg in dremio.pkgs %}
test_{{pkg}}_is_installed:
  testinfra.package:
    - name: {{ pkg }}
    - is_installed: True
{% endfor %}

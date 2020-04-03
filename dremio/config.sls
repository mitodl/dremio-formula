#!pyobjects
from pyhocon import HOCONConverter, ConfigFactory
from xml.dom import minidom
from xml.etree.ElementTree import Element, SubElement, tostring
from salt.ext import six

def from_dict(xml_dict, indent=2):
    def normalize_iter(value):
        if isinstance(value, (list, tuple)):
            if isinstance(value[0], str):
                xmlval = value
            else:
                xmlval = []
        elif isinstance(value, dict):
            xmlval = list(value.items())
        else:
            raise TemplateRuntimeError(
                'Value is not a dict or list. Cannot render as XML')
        return xmlval

    def recurse_tree(xmliter, element=None):
        sub = None
        for tag, attrs in xmliter:
            if isinstance(attrs, list):
                for attr in attrs:
                    recurse_tree(((tag, attr),), element)
            elif element is not None:
                sub = SubElement(element, tag)
            else:
                sub = Element(tag)
            if isinstance(attrs, (str, int, bool, float)):
                sub.text = six.text_type(attrs)
                continue
            if isinstance(attrs, dict):
                sub.attrib = {attr: six.text_type(val) for attr, val in attrs.items()
                              if not isinstance(val, (dict, list))}
            for tag, val in [item for item in normalize_iter(attrs) if
                             isinstance(item[1], (dict, list))]:
                recurse_tree(((tag, val),), sub)
        return sub

    return minidom.parseString(
        tostring(
            recurse_tree(
                normalize_iter(
                    xml_dict
                )
            )
        )
    ).toprettyxml(indent=" "*indent)

dremio = salt.jinja.load_map('dremio/map.jinja', 'dremio')

include('.service')

conf = ConfigFactory.from_dict(dremio['config'])

File.managed('write_dremio_config',
             name=dremio['conf_file'],
             contents=HOCONConverter.to_hocon(conf),
             makedirs=True,
             user=dremio['user'],
             group=dremio['group'],
             watch_in=[Service('dremio_service_running')])

if dremio['core_site_config']:
    File.managed('write_dremio_site_config',
                 name='/opt/dremio/conf/core-site.xml',
                 contents=from_dict(dremio['core_site_config']),
                 user=dremio['user'],
                 group=dremio['group'],
                 watch_in=[Service('dremio_service_running')])

from pyVim.connect import SmartConnect, Disconnect
import ssl
import atexit
from pyVmomi import vim, vmodl, VmomiSupport
import time


def connect(hostname, username, password):
    context = ssl._create_unverified_context()
    context.verify_mode = ssl.CERT_NONE

    si = SmartConnect(host=hostname, user=username, pwd=password, port=443, sslContext=context)
    atexit.register(Disconnect, si)
    content = si.RetrieveContent()
    return content

def get_obj(content, vimtype, name):
    """
    Return an object by name, if name is None the
    first found object is returned
    """
    obj = None
    if name in ['', None]:
        obj = []
    container = content.viewManager.CreateContainerView(content.rootFolder, vimtype, True)
    for c in container.view:
        if name:
            if c.name == name:
                obj = c
                break
        else:
            obj.append(c)

    container.Destroy()
    return obj

hostname = 'weblovcenter65.cpr.sncf.fr'
username = 'ansible@vsphere.local'
password = 'Zj]h&3OFD9d2YQccbSK'
content = connect(hostname, username, password)

# -*- mode: python; python-indent: 4 -*-
import ncs
from ncs.application import Service

class ServiceCallbacks(Service):

    @Service.create
    def cb_create(self, tctx, root, service, proplist):
        self.log.info('Service create(service=', service._path, ')')

        vlan_id = self.allocate_vlan(service.client_name)
        service.vlan_id = vlan_id

        vars = ncs.template.Variables()
        vars.add('DUMMY', '127.0.0.1')
        template = ncs.template.Template(service)
        template.apply('arvpn-svc-template', vars)

        if service.service_level_agreement in ['gold', 'platinum']:
            template.apply('arvpn-svc-template-extras', vars)

    def allocate_vlan(self, publisher):
        # Let's make this as simple as possible for now:
        # Just return a hash on the name (1000..2999)
        return 1000 + hash(publisher.name) % 2000


class Main(ncs.application.Application):
    def setup(self):
        self.log.info('Main RUNNING')
        self.register_service('arvpn-svc-servicepoint', ServiceCallbacks)
    def teardown(self):
        self.log.info('Main FINISHED')
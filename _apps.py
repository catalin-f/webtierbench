from _base import Application

#TODO: add all apps here
#TODO: refactor the code in _base::Deployment to not create a new Application when calling add_*, set_client


class Apache(Application):
    def __init__(self, name, config, distribution, version):
        super(Apache, self).__init__(name, config, distribution, version)

    def start(self, async=False):
        print("in start din Apache")
        print self.config["ip"]
        print self.config["port"]
        print self.name
        #super(Apache, self).start(async)


ap = Apache("apache2", {"ip": "localhost", "port": "80"}, 'ubuntu', '16.04')
ap.start()

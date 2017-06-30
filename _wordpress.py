from base import debugLogger
from base import _Applications

class Wordpress(_Applications):
    
    def deploy(self):
        debugLogger("will deploy Wordpress")

    def undepoy(self):
        debugLogger("will undeploy Wordpress")

    def start(self):
        debugLogger("will start Wordpress")
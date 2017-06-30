from base import debugLogger
from base import _Applications

class measure(_Applications):

    def deploy(self):
        debugLogger("will deploy measure")

    def undepoy(self):
        debugLogger("will undeploy measure")

    def start(self):
        debugLogger("will start measure")

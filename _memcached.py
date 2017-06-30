from base import debugLogger
from base import _Applications

class MemCached(_Applications):

    def deploy(self):
        debugLogger("will deploy MemCached ")

    def undepoy(self):
        debugLogger("will undeploy MemCached")

    def start(self):
        debugLogger("will start MemCached")

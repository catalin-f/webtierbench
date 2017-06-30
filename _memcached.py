from base import debugLogger
from base import _Applications

class MemCached(_Applications):

    def __init__(self, mctype, mcip, mcport):
        self.mctype = mctype
        self.mcip = mcip
        self.mcport = mcport

    def deploy(self):
        debugLogger("will deploy MemCached ")

    def undepoy(self):
        debugLogger("will undeploy MemCached")

    def start(self):
        debugLogger("will start MemCached")

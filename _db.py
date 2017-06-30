from base import debugLogger
from base import _Applications

class DB(_Applications):

    def __init__(self, dbtype, dbip, dbport):
        self.dbtype = dbtype
        self.dbip = dbip
        self.dbport = dbport

    def deploy(self):
        debugLogger("will deploy DB")

    def undepoy(self):
        debugLogger("will undeploy DB")

    def start(self):
        debugLogger("will start DB")


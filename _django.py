from _base import debugLogger
from _base import _Application


class Django(_Application):
    def deploy(self):
        debugLogger("will deploy django")

    def undeploy(self):
        debugLogger("will undeploy django")

    def start(self):
        debugLogger("will start django")
import datetime


###############################################################################
# Logging
###############################################################################
class _Logger:
    def __init__(self, filename, fullMode=True):
        self.filename = filename
        self.fd = open(filename, "a")
        self.fullMode = fullMode

    def _get_prefix(self):
        if self.fullMode:
            today = datetime.date.today()
            return "[%s] " % today.strftime('%Y-%m-%d %H:%M:%S')
        return ""

    def log(self, text):
        self.fd.write("%s%s\n" % (self._get_prefix(), text))
        self.fd.flush()

debugLogger = _Logger("webtierbench.log").log
masterLogger = _Logger("results.log", fullMode=False).log


###############################################################################
# Application base class
###############################################################################
class _Application:
    def __init__(self, apptype, dbtype, memcached, measuremeth ):
        self.apptype = apptype #Django, wordpress ...
        self.dbtype = dbtype # mariadb, cassandra ..
        self.memcached = memcached # identify if memcached is going to be used
        self.measuremeth  = measuremeth #perf,emon .. this can be a list if more then one is nedeed
        pass

    def deploy(self):
        raise NotImplementedError("Method not implemented")

    def undeploy(self):
        raise NotImplementedError("Method not implemented")

    def start(self):
        raise NotImplementedError("Method not implemented")

    def stop(self):
        raise NotImplementedError("Method not implemented")

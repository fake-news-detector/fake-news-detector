import tornado.ioloop
import tornado.web
from robinho.model import Robinho
from robinho.classifiers.keywords import Keywords
import os

robinho = Robinho()
keywords_model = Keywords()


class MainHandler(tornado.web.RequestHandler):
    def get(self):
        title = self.get_arguments("title")[0]
        content = self.get_arguments("content")[0]
        predictions = robinho.predict(title, content)
        keywords = keywords_model.find_keywords(title, content)

        self.finish({'predictions': predictions, 'keywords': keywords})


class HealthCheckHandler(tornado.web.RequestHandler):
    def get(self):
        self.finish('OK')


def start():
    app = tornado.web.Application([
        (r"/predict", MainHandler),
        (r"/healthcheck", HealthCheckHandler),
    ])
    port = os.getenv("PORT") or 8888
    app.listen(port)
    print("Server listening at http://localhost:" + str(port))
    tornado.ioloop.IOLoop.current().start()

import tornado.ioloop
import tornado.web
from robinho.model import Robinho
import os

robinho = Robinho()


class MainHandler(tornado.web.RequestHandler):
    def get(self):
        title = self.get_arguments("title")[0]
        content = self.get_arguments("content")[0]
        predictions = robinho.predict(title, content)

        self.finish({'predictions': predictions})


def start():
    app = tornado.web.Application([
        (r"/predict", MainHandler),
    ])
    port = os.getenv("PORT") or 8888
    app.listen(port)
    print("Server listening at http://localhost:" + str(port))
    tornado.ioloop.IOLoop.current().start()

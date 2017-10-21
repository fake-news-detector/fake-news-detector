import tornado.ioloop
import tornado.web
from robinho.model import Robinho
import robinho.common as common
import robinho.fake_news as fake_news
import robinho.click_bait as click_bait
import robinho.extremely_biased as extremely_biased
import os


def handler(robinho):
    class MainHandler(tornado.web.RequestHandler):
        def get(self):
            title = self.get_arguments("title")[0]
            predictions = robinho.predict(title)

            self.finish({'predictions': predictions})

    return MainHandler


def start():
    robinho = Robinho()
    robinho.load()
    app = tornado.web.Application([
        (r"/predict", handler(robinho)),
    ])
    port = os.getenv("PORT") or 8888
    app.listen(port)
    print("Server listening at http://localhost:" + str(port))
    tornado.ioloop.IOLoop.current().start()

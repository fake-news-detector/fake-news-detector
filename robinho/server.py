import tornado.ioloop
import tornado.web
import robinho.model as robinho
import os


def handler(model):
    class MainHandler(tornado.web.RequestHandler):
        def get(self):
            titles = self.get_arguments("title")
            predictions = model.predict_proba(titles)[0]
            predictions = [{
                'category_id': index + 1,
                'chance': chance
            } for index, chance in enumerate(predictions)]

            self.finish({'predictions': predictions})

    return MainHandler


def start():
    model = robinho.load_model()
    app = tornado.web.Application([
        (r"/predict", handler(model)),
    ])
    port = os.getenv("PORT") or 8888
    app.listen(port)
    print("Server listening at http://localhost:" + str(port))
    tornado.ioloop.IOLoop.current().start()

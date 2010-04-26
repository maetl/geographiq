import os
import yaml
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.ext.webapp import template

class IndexHandler(webapp.RequestHandler):

  def get(self):
    page_vars = yaml.load(open(os.path.join(os.path.dirname(__file__), 'templates/locales/en.yaml')))
    path = os.path.join(os.path.dirname(__file__), 'templates/index.html')
    self.response.out.write(template.render(path, page_vars))


def main():
  application = webapp.WSGIApplication([('/', IndexHandler)], debug=True)
  util.run_wsgi_app(application)

if __name__ == '__main__':
  main()

#!/usr/bin/env python

import os
import yaml
import urllib2
from BeautifulSoup import BeautifulSoup


def main():
  currencies = {}
  languages = {}
  territories = {}

  extract_lang_code = 'fr'
  
  page = urllib2.urlopen('http://unicode.org/repos/cldr-tmp/trunk/diff/summary/' + extract_lang_code + '.html')
  soup = BeautifulSoup(page)
  table = soup.findAll('table', border='1')
  for tr in table[0].findAll('tr'):

    td = tr('td')
    if not td:
      continue

    if extract_lang_code == 'en':
      value_cell = 4
    else:
      value_cell = 5
    
    if td[2].contents == [u'currency']:
      path = td[3].string.split(':')
      if not len(path) > 1:
        continue
      currency_code = path[0].encode('ascii')
      path_key = path[1].encode('ascii', 'ignore').replace('/', '-')
      if not currency_code in currencies:
        currencies[currency_code] = {}
      currencies[currency_code][path_key] = str(td[value_cell].string)

    if td[2].contents == [u'language']:
      locale_code = td[3].string.encode('ascii', 'ignore')
      languages[locale_code] = str(td[value_cell].string)

    if td[2].contents == [u'territory']:
      key_number = td[3].string.encode('ascii', 'ignore')
      territories[key_number] = str(td[value_cell].string)
	  
  c = file(extract_lang_code + '_currencies.yaml', 'w')
  yaml.dump(currencies, c)

  l = file(extract_lang_code + '_languages.yaml', 'w')
  yaml.dump(languages, l)
  
  t = file(extract_lang_code + '_territories.yaml', 'w')
  yaml.dump(territories, t)


if __name__ == '__main__':
  main()
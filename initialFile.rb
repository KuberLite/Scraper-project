require 'nokogiri'
require 'curb'
require 'mechanize'
require 'csv'
require_relative 'Scraper'

file_path = 'export.csv'
category = 'https://www.petsonic.com/snacks-huesos-para-perros/'
scraper_info = Scraper.new(category, file_path)
scraper_info.get_category_items
scraper_info.export_into_csv(file_path)
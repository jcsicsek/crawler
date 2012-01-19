require 'net/http'
require 'uri'
require 'open-uri'
require 'rubygems'
require 'hpricot'
require 'url_utils'

class Spider
  include UrlUtils
  
  def initialize
    @already_visited = {}
    @total_visited = 0
    @results = []
  end
  
  def get_results
    puts @results
    @results
  end

  def crawl_domain(url, page_limit = 100)
    @already_visited[url]=true if @already_visited[url] == nil
    return if @total_visited >= page_limit
    url_object = open_url(url)
    return if url_object == nil
    parsed_url = parse_url(url_object)
    return if parsed_url == nil
    data = scrape_data(parsed_url)
    data[:url] = url
    @total_visited += 1
    @results.push(data)
    page_urls = find_urls_on_page(parsed_url, url)
    page_urls.each do |page_url|
      if urls_on_same_domain?(url, page_url) and @already_visited[page_url] == nil
        crawl_domain(page_url, page_limit)
      end
    end
  end

  def open_url(url)
    url_object = nil
    begin
      url_object = open(url)
    rescue
      puts "Unable to open url: " + url
    end
    return url_object
  end

  def update_url_if_redirected(url, url_object)
    if url != url_object.base_uri.to_s
      return url_object.base_uri.to_s
    end
    return url
  end

  def parse_url(url_object)
    doc = nil
    begin
      doc = Hpricot(url_object)
    rescue
      puts 'Could not parse url: ' + url_object.base_uri.to_s
    end
    puts 'Crawling url ' + url_object.base_uri.to_s
    return doc
  end
  
  def scrape_data(parsed_url)
    title_tags = parsed_url.search('title')
    meta_tags = parsed_url.search('meta')
    meta_arr = Array.new
    meta_tags.each do |meta|
      meta_arr.push(meta.attributes)
    end
    {:title => title_tags[0].inner_html, :meta => meta_arr}
  end

  def find_urls_on_page(parsed_url, current_url)
    urls_list = []
    parsed_url.search('a[@href]').map do |x|
      new_url = x['href'].split('#')[0]
      unless new_url == nil
        if relative?(new_url)
         new_url = make_absolute(current_url, new_url)
        end
        urls_list.push(new_url)
      end
    end
    return urls_list
  end

  #private :open_url, :update_url_if_redirected, :parse_url, :find_urls_on_page
end


    


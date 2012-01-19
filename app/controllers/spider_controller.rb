class SpiderController < ApplicationController
  def new
  end

  def show
    @url = params[:url]
    if (params[:max_pages])
      max_pages = params[:max_pages].to_i
    else
      max_pages = 10
    end
    spider = Spider.new
    spider.crawl_domain("http://" + @url, max_pages)
    @xml = Builder::XmlMarkup.new
    @results = spider.get_results
    #@results = ["dog", "cat", "skateboard"]
  end

end

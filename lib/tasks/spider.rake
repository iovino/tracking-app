require 'open-uri'

namespace :spider do
  desc ""
  task crawl: :environment do
    # get all active sites
    sites = Site.where(:active => true)
    sites.each do |site|
      # crawl current site
      spider = Spider.new(site)
      spider.crawl

      # check for errors
      if spider.errors.any?
        spider.errors.each do |error|
          SiteError.new(:message => error, :site_id => site.id).save
        end
        site.status = :missing;
      else
        site.status = :found;
      end

      site.last_checked = DateTime.now
      site.save
    end
  end
end

class Spider
  #
  # Constructor
  #
  def initialize(site)
    @site   = site
    @errors = []
  end

  #
  # Returns array of errors if any
  #
  def errors
    @errors
  end

  #
  # Initiates the crawl
  #
  def crawl
    urls = []

    # add homepage
    urls.push(@site.homepage)

    # add prioritize urls
    unless @site.site_urls.empty?
      @site.site_urls.each do |site_url|
        urls.push(site_url.url)
      end
    end

    urls.each do |url|
      crawl_url(url)
    end
  end

  #
  # Crawls a url to see if the ua-codes are found
  #
  def crawl_url(url)
    begin
      begin
        source = Nokogiri::HTML(open(clean_url(url), :allow_redirections => :all))
      rescue => e
        @errors.push(e.message)
      end

      # get all ua-codes from source code
      uacodes = get_uacodes(source)

      # were any ua-codes found?
      if uacodes.empty?
        @errors.push("Failed to find UA codes on: #{url}")
      end

      # check if ua-codes found match what's saved in the database
      @site.ua_codes.split(',').each do |ua_code|
        unless uacodes.include?(ua_code.tr(' ', ''))
          @errors.push("Could not find the following UA-Code: #{ua_code}")
        end
      end
    rescue => e
      @errors.push(e.message)
    end

  end

  #
  # Returns an array of Google UA-Codes if any are found
  #
  def get_uacodes(html)

    codes = []

    html = html.to_s
    html = html.gsub(/<!--[\s\S]*?-->/, '')

    html.scan(/UA-[0-9]{5,}-[0-9]{1,}/).each do |ua_code|
      codes.push(ua_code)
    end

    html.scan(/GTM-[0-9A-Z]{5,}/).each do |gtm_code|
      codes.push(gtm_code)
    end

    return codes.uniq
  end

  #
  # Removes hashtags from URLs
  #
  def clean_url(url)
    url.gsub(/(#(.*))/i, '')
  end
end
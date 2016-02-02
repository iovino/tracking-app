require 'open-uri'

namespace :spider do

  desc "Crawls the homepage of all sites and looks for UA codes"
  task crawl_all: :environment do

    sites = Site.where(:active => true)
    sites.each do |site|
      spider = Spider.new(site)
      spider.crawl_homepage
      #spider.crawl_links
      #spider.crawl_prioritize_urls

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



    # Rake::Task['spider:crawl_homepages'].invoke
    # Rake::Task['spider:crawl_links'].invoke
    # Rake::Task['spider:crawl_prioritize_urls'].invoke
  end

  desc "Crawls the homepage of all sites and looks for UA codes"
  task crawl_homepages: :environment do
    sites = Site.where(:active => true)
    sites.each do |site|
      spider = Spider.new(site)
      spider.crawl_homepage

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

  desc "Crawls the homepage of all sites and looks for UA codes"
  task crawl_links: :environment do
    sites = Site.where(:active => true)
    sites.each do |site|
      spider = Spider.new(site)
      spider.crawl_links

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

  desc "Crawls the homepage of all sites and looks for UA codes"
  task crawl_prioritize_urls: :environment do
    sites = Site.where(:active => true)
    sites.each do |site|
      spider = Spider.new(site)

      if spider.crawl_prioritize_urls == false
        next
      end

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
  # Crawls all links on a site's homepage and looks for UA codes
  #
  def crawl_links
    # get the url's source code
    begin
      source = Nokogiri::HTML(open(clean_url(@site.homepage)))
    rescue => e
      @errors.push(e.message)
    end

    links = get_links(source)
    links.each do |link|

      link = clean_url(link)

      # don't include the homepage
      if link == @site.homepage
        next
      end

      # only include pages that link to another page of the site
      if !link.include? @site.homepage
        next
      end

      # don't include images
      if link.include? '.jpg' or link.include? '.png' or link.include? '.gif'
        next
      end

      # get the link's source code
      begin
        link_source = Nokogiri::HTML(open(link))
      rescue => e
        @errors.push(e.message)
        next
      end

      # get all UA codes
      uacodes = get_tracking(link_source)

      # no UA codes found
      if uacodes.empty?
        @errors.push("Failed to find UA codes on: #{link}")
        next
      end

      # check if UA codes found match what's saved in the database
      @site.ua_codes.split(',').each do |ua_code|
        if (uacodes.include? ua_code) == false
          @errors.push("Mismatched UA Codes on: #{link}")
        end
      end

    end

  end
  
  #
  # Crawls a site's homepage and looks for UA codes
  #
  def crawl_homepage
    # get the url's source code
    begin
      source = Nokogiri::HTML(open(clean_url(@site.homepage)))
    rescue => e
      @errors.push(e.message)
    end

    # get all UA codes
    uacodes = get_tracking(source)

    # no UA codes found
    if uacodes.empty?
      @errors.push("Failed to find UA codes on: #{@site.homepage}")
    end

    # check if UA codes found match what's saved in the database
    @site.ua_codes.split(',').each do |ua_code|

      if (uacodes.include? ua_code) == false
        @errors.push("Mismatched UA Codes on: #{@site.homepage}")
      end
    end

  end

  #
  #
  #
  def crawl_prioritize_urls

    if @site.site_urls.empty?
      return false
    end

    @site.site_urls.each do |site_url|
      # get the url's source code
      begin
        source = Nokogiri::HTML(open(clean_url(site_url.url)))
      rescue => e
        @errors.push(e.message)
      end

      # get all UA codes
      uacodes = get_tracking(source)

      # no UA codes found
      if uacodes.empty?
        @errors.push("Failed to find UA codes on: #{site_url.url}")
      end

      # check if UA codes found match what's saved in the database
      @site.ua_codes.split(',').each do |ua_code|
        if (uacodes.include? ua_code) == false
          @errors.push("Mismatched UA Codes on: #{site_url.url}")
        end
      end
    end

  end

  #
  # Returns array of errors if any
  #
  def errors
    @errors
  end

  private

  #
  # Scans a pages HTML source and returns all UA codes if any are found
  #
  def get_tracking(html)
    uacodes = []
    scripts = html.to_s.scan(/<script\b[^>]*>([\s\S]*?)<\/script>/i)

    if scripts.empty?
      return uacodes
    end

    scripts.each do |tag|
      tracking = tag.to_s.scan(/UA-[0-9]{5,}-[0-9]{1,}/)

      if tracking.empty? == false
        uacodes.push(tracking.first.to_s)
      end
    end

    return uacodes
  end

  #
  # Returns all links from the HTML source code provided
  #
  def get_links(html)
    links = html.css('a')
    hrefs = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
    return hrefs
  end

  def clean_url(url)
    url.gsub(/(#(.*))/i, '')
  end
end

























# return Google's UA code if found
def find_and_return_ua_code(html)
  tags = html.to_s.scan(/<script\b[^>]*>([\s\S]*?)<\/script>/i)

  if tags.empty?
    return false
  end

  tags.each do |tag|
    google_tag = tag.to_s.scan(/UA-[0-9]{5,}-[0-9]{1,}/)
    if google_tag.empty? == false
      return google_tag.first.to_s
    end
  end

  return false
end

# method that will get all links using Nokogiri
def get_all_hrefs_nokogiri(html)
  links = html.css('a')
  hrefs = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
  return hrefs
end
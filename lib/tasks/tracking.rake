require 'open-uri'

namespace :tracking do
  desc "Check all Sites for tracking issues"
  task check: :environment do

    # get all sites
    Site.all.each do |site|

      has_tracking = false

      puts '--------------------------------------------------------'
      puts "Trying #{site.homepage}..."
      puts '--------------------------------------------------------'

      # check if site is active
      if site.active == false
        puts 'Site not active, skipping.'
        next
      end

      # attempt to get site's HTML
      begin
        html = Nokogiri::HTML(open(site.homepage))
      rescue => e
        site.status       = :missing;
        site.last_checked = DateTime.now
        site.save
        puts 'Tracking Not Found!'
        SiteError.new(:message => e.message, :site_id => site.id).save
        next
      end

      # get all contents of anything inside a script tag
      tags = html.to_s.scan(/<script\b[^>]*>([\s\S]*?)<\/script>/i)

      # no script tags found
      if tags.empty?
        SiteError.new(:message => 'Failed to find any script tags on the site', :site_id => site.id).save
        next
      end

      # go through each script tag and look for Google's UA code
      tags.each do |tag|
        google_tag = tag.to_s.scan(/UA-[0-9]{5,}-[0-9]{1,}/)
        if google_tag.empty? == false
          has_tracking = true
          site.ua_code = google_tag.first
          break
        end
      end

      if has_tracking
        site.status       = :found;
        site.last_checked = DateTime.now
        site.save
        puts 'Tracking Found!'
      else
        site.status       = :missing;
        site.last_checked = DateTime.now
        site.save
        SiteError.new(:message => 'Failed to find any tracking tags on the site', :site_id => site.id).save
        puts 'Tracking Not Found!'
      end

    end
  end
end

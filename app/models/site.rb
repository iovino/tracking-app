class Site < ActiveRecord::Base
  has_many :site_errors, :dependent => :destroy
  has_many :site_urls, :dependent => :destroy
  belongs_to :user

  enum status: [:missing, :found, :pending]

  validates_presence_of :name
  validates_presence_of :homepage
  validates_presence_of :ua_codes
end

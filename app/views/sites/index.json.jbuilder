json.array!(@sites) do |site|
  json.extract! site, :id, :name, :url, :status, :active, :last_checked
  json.url site_url(site, format: :json)
end

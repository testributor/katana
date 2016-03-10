host = ENV['CANONICAL_HOST'] || 'www.example.com'
SitemapGenerator::Sitemap.default_host = "http://#{host}"
SitemapGenerator::Sitemap.public_path = 'public/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

# if bucket name is not set in ENV, it will not upload the sitemaps
if ENV['S3_BUCKET_NAME']
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new({
    fog_provider: 'AWS',
    fog_directory: ENV['S3_BUCKET_NAME'],
    aws_access_key_id: ENV['S3_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY_ID'],
    fog_region: ENV['FOG_REGION']
  })
  SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['S3_BUCKET_NAME']}.s3.amazonaws.com/"
end

SitemapGenerator::Sitemap.create do
  add root_path

  # pages
  Dir['app/views/pages/*.haml'].map { |f| File.basename(f.to_s, '.html.haml') }.each do |page|
    add pages_path(page)
  end
end

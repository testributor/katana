# If the generation of the sitemap starts to take too long, it might be a good
# idea to "warm up" the cache instead of waiting for bots to use this endpoint.
# For example a cron job could be used to put the sitemap in cache. An other
# type of storage could also be used instead of cache if the sitemap grows too
# big (e.g. database).
#
# This implementation has the benefit that is doesn't rely on any external
# service (like AWS S3) to store and serve the sitemap and works on all hosting
# solutions (like Heroku) with no external dependencies.
class SitemapController < ApplicationController
  def show
    cached_result = Rails.cache.fetch("sitemap", expires_in: 1.day) do
      @public_projects = Project.non_private.includes(tracked_branches: :test_runs)

      result = StringIO.new
      gzip_writer = Zlib::GzipWriter.new(result)
      gzip_writer.write render_to_string('sitemap/show')
      gzip_writer.close

      result.string
    end

    respond_to do |format|
      format.xml_gz { send_data cached_result, filename: 'sitemap.xml.gz' }
    end
  end
end

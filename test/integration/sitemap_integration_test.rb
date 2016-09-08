require 'test_helper'

class SitemapIntegrationTest < ActionDispatch::IntegrationTest
  describe "when requesting /sitemap.xml.gz" do
    let(:_test_run_private) { FactoryGirl.create(:testributor_run) }
    let(:_test_run) { FactoryGirl.create(:testributor_run) }

    before do
      _test_run.project.update_column(:is_private, false)
      get '/sitemap.xml.gz'
    end

    it 'should return a sitemap with the correct contents' do
      response.status.must_equal 200

      tempfile = Tempfile.new('sitemap.xml.gz')
      File.open(tempfile.path, 'w') do |f|
        f.write response.body
      end

      xml_string = Zlib::GzipReader.open(tempfile) { |f| f.read }
      doc = Nokogiri::XML(xml_string)
      urls = doc.xpath('//s:loc', 's' => 'http://www.sitemaps.org/schemas/sitemap/0.9').map(&:text)

      urls.must_include project_url(_test_run.project, branch: _test_run.tracked_branch.branch_name)
      urls.must_include project_test_run_url(_test_run.project, _test_run)
      urls.wont_include project_url(_test_run_private.project, branch: _test_run_private.tracked_branch.branch_name)
      urls.wont_include project_test_run_url(_test_run_private.project, _test_run_private)
    end
  end
end

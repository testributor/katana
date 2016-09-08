xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'

xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url do
    xml.loc new_user_session_url
  end
  
  xml.url do
    xml.loc new_user_registration_url
  end
  
  @public_projects.each do |project|
    project.tracked_branches.each do |tracked_branch|
      xml.url do
        xml.loc project_url(project, branch: tracked_branch.branch_name)
        xml.changefreq 'hourly'
        xml.lastmod tracked_branch.test_runs.sort_by{|tr|tr.updated_at}.reverse.
          first.try(:updated_at).try(:iso8601) || tracked_branch.updated_at.iso8601
      end

      tracked_branch.test_runs.each do |test_run|
        xml.url do
          xml.loc project_test_run_url(project, test_run)
          xml.changefreq test_run.status.terminal? ? 'never' : 'hourly'
          xml.lastmod test_run.updated_at.strftime('%Y-%m-%d')
        end
      end
    end
  end
end
